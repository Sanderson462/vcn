# Signatures

A signature is made by the user by using a key (*the signer*), usually by running the `vcn sign` command on an asset.

Assets' signatures are stored onto the [ZTC](https://zerotrustconsortium.org/) blockchain and are used for verifications.

Each signature includes the following:

Field | Label | Description 
------------ | ------------- | ------------- 
`Owner` | **Key** | The signer's wallet address, also kwown as the signer key.
`Level` | **Level** | The signer's [level](#Levels) at the time when the signature was made.
`Status` | **Status** | The asset's [status](#Statuses) chosen by the signer at the time when the signature was made.
`Timestamp` | **Date** | The date and time of the signature.
> *Name* represents the [field stored onto the blockchain](https://github.com/vchain-us/vcn/blob/0.5.0/pkg/api/verify.go#L26), *Label* is used by `vcn` when priting results.

## Statuses

Code | Status | Color | Description | Error message | Explanation
------------ | ------------- | ------------- | ------------ | ------------- | -------------
0 | **TRUSTED** | *green* | The asset was signed. | *none* | The signature on the blockchain indicates that the signer trusts that asset.
2 | **UNKNOWN** | *yellow* | The asset was not signed. | *hash* was not signed *[by <key/list of keys/org>]* | There's no signature on the blockchain.
1 | **UNTRUSTED** | *red* | The asset is untrusted. | *hash* was is untrusted *[by <key/list of keys/org>]* | The signature on the blockchain indicates that the signer DOES NOT trust that asset.
3 | **UNSUPPORTED** | *red* | The asset is unsupported. | *hash* was is unsupported *[by <key/list of keys/org>]* | The signature on the blockchain indicates that the signer DOES NOT trust that asset because it is not supported anymore (eg. deprecated).

## Levels

Level | Label | Description 
------------ | ------------- | ------------- 
-1 | **DISABLED** | The signer's account is disabled.
0 | **UNKNOWN** | The signer's identity is unknown.
1 | **EMAIL_VERIFIED** | The signer's email is verified by CodeNotary platform.
2 | **SOCIAL_VERIFIED** | The signer's identity is verified by social media profiles.
3 | **ID_VERIFIED** | The signer provided an ID document.
4 | **LOCATION_VERIFIED** | The signer provided a proof-of-address.
99 | **VCHAIN** | *Reserved*
