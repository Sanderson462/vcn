/*
 * Copyright (c) 2018-2019 vChain, Inc. All Rights Reserved.
 * This software is released under GPL3.
 * The full license information can be found under:
 * https://www.gnu.org/licenses/gpl-3.0.en.html
 */

package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"

	"github.com/dghubble/sling"
	"github.com/sirupsen/logrus"
)

type AuthRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type TokenResponse struct {
	Token string `token:"token"`
}

type Error struct {
	Status    int    `json:"status"`
	Message   string `json:"message"`
	Path      string `json:"path"`
	Timestamp string `json:"timestamp"`
	Error     string `json:"error"`
}

type PublisherExistsResponse struct {
	Exists bool `json:"exists"`
}
type PublisherExistsParams struct {
	Email string `url:"email"`
}
type PublisherResponse struct {
	Authorities []string `json:"authorities"`
	Email       string   `json:"email"`
	FirstName   string   `json:"firstName"`
	LastName    string   `json:"lastName"`
}

type LoginTrackerRequest struct {
	Name string `json:"name"`
}

func loginTracker(token string) {

	LOG.Trace("loginTracker() started")

	// make sure the tracker does its analytics although the main
	// thread has already finalized
	defer WG.Done()

	restError := new(Error)
	r, err := sling.New().
		Post(TrackingEvent()+"/publisher").
		Add("Authorization", "Bearer "+token).
		BodyJSON(LoginTrackerRequest{
			Name: "VCN_LOGIN",
		}).Receive(nil, restError)
	if err != nil {
		LOG.WithFields(logrus.Fields{
			"version": VCN_VERSION,
		}).Warn("Login analytics seems broken: %s", err)

	}
	if r.StatusCode != 200 {
		LOG.WithFields(logrus.Fields{
			"errorMsg": restError.Message,
			"status":   restError.Status,
		}).Warn("Login analytics API failed")
	}

	LOG.Trace("loginTracker() finished")

}

func CheckPublisherExists(email string) (ret bool) {

	email = strings.TrimSpace(email)

	params := &PublisherExistsParams{Email: email}
	response := new(PublisherExistsResponse)
	restError := new(Error)

	r, err := sling.New().
		Get(PublisherEndpoint()+"/exists").
		QueryStruct(params).
		Receive(&response, restError)

	if err != nil {
		fmt.Printf(err.Error())
		return false
	}
	if r.StatusCode != 200 {

		fmt.Printf(fmt.Sprintf("request failed: %s (%d)",
			restError.Message, restError.Status))
		return false
	}

	return response.Exists
}

func CheckToken(token string) (ret bool) {

	if token == "" {
		return false
	}

	restError := new(Error)

	r, err := sling.New().
		Get(TokenCheckEndpoint()).
		Add("Authorization", "Bearer "+token).
		Receive(nil, restError)

	if err != nil {
		LOG.WithFields(logrus.Fields{
			"error": err,
		}).Debug("Token invalid")
		return false
	}
	switch r.StatusCode {
	case 403:
		LOG.WithFields(logrus.Fields{
			"error": err,
		}).Error("Token not found")
	case 419:
		LOG.WithFields(logrus.Fields{
			"error": err,
		}).Error("Token expired")
	case 200:
		return true
	}

	return false
}

func Authenticate(email string, password string) (ret bool, code int) {

	token := new(TokenResponse)
	authError := new(Error)

	r, err := sling.New().
		Post(PublisherEndpoint()+"/auth").
		BodyJSON(AuthRequest{Email: email, Password: password}).
		Receive(token, authError)
	if err != nil {
		log.Fatal(err)
	}
	if r.StatusCode != 200 {

		LOG.WithFields(logrus.Fields{
			"code":  r.StatusCode,
			"error": authError.Message,
		}).Error("API request failed")

		return false, authError.Status

	}
	err = ioutil.WriteFile(TokenFile(), []byte(token.Token),
		os.FileMode(0600))
	if err != nil {
		log.Fatal(err)
	}

	return true, 0

}

// Register creates an Account with vChain.us
func Register(email string, accountPassword string) (ret bool, code int) {

	authError := new(Error)
	//var apiError string

	r, err := sling.New().
		Post(PublisherEndpoint()).
		BodyJSON(AuthRequest{Email: email, Password: accountPassword}).
		Receive(nil, authError)
	if err != nil {
		log.Fatal(err)
	}
	if r.StatusCode != 200 {
		//GET-v1-artifact-404
		// TODO debug log
		log.Printf("request failed: %s (%d)", authError.Message, authError.Status)

		return false, authError.Status
	}
	return true, 0
}

func LoadToken() (jwtToken string, err error) {
	contents, err := ioutil.ReadFile(TokenFile())
	if err != nil {
		return "", err
	}
	return string(contents), nil
}
