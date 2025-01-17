;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General

  ;Name and file
  Name "CodeNotary vcn {VCN_VERSION}"
  OutFile "codenotary_vcn_{VCN_VERSION}_setup.exe"
  Icon "vcn.ico"
  LicenseData "gpl3license.txt"
  
  ;Default installation folder
  InstallDir "$PROGRAMFILES64\CodeNotary"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\CodeNotary" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

  SetCompressor /SOLID LZMA
;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_ICON vcn.ico
  

;--------------------------------
;Pages
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "gpl3license.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"
 
 
;-------------------------------- 
;Installer Sections

Section "CodeNotary vcn cli tool" installation
 
;Add files
  SetOutPath "$INSTDIR"
 
  File "vcn.exe"
  File "vcn.ico"
  File "gpl3license.txt"
 
;create desktop shortcut
  SetOutPath "$INSTDIR"
  CreateShortCut "$DESKTOP\vcn.lnk" "cmd.exe" "" "$INSTDIR\vcn.ico"
 
;create start-menu items
  CreateDirectory "$INSTDIR"
  CreateShortCut "$INSTDIR\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
  CreateShortCut "$INSTDIR\vcn.lnk" "$INSTDIR\vcn.exe" "" "$INSTDIR\vcn.exe" 0

;create context menu  
  WriteRegStr HKCR "*\shell" "" "CodeNotary verify"
  WriteRegStr HKCR "*\shell\CodeNotary verify" "Icon" "$INSTDIR\vcn.ico,0" 
  WriteRegStr HKCR "*\shell\CodeNotary verify\command" ""  '"$INSTDIR\vcn.exe" verify "%1"' 
  
  WriteRegStr HKCR "*\shell" "" "CodeNotary sign"
  WriteRegStr HKCR "*\shell\CodeNotary sign" "Icon" "$INSTDIR\vcn.ico,0" 
  WriteRegStr HKCR "*\shell\CodeNotary sign\command" "" '"$INSTDIR\vcn.exe" sign "%1"' 

  
;write uninstall information to the registry
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CodeNotary" "DisplayName" "vcn (remove only)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CodeNotary" "UninstallString" "$INSTDIR\Uninstall.exe"
 
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  
SectionEnd

  ;Language strings
  LangString DESC_Installation ${LANG_ENGLISH} "vChain CodeNotary vcn command line"

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${Installation} $(DESC_Installation)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------    
;Uninstaller Section  
Section "Uninstall"
 
;Delete Files 
  RMDir /r "$INSTDIR\*.*"    
 
;Remove the installation directory
  RMDir "$INSTDIR"
 
;Delete Start Menu Shortcuts
  Delete "$DESKTOP\vcn.lnk"

;Delete Uninstaller And Unistall Registry Entries
  DeleteRegKey HKCR "*\shell\CodeNotary verify"
  DeleteRegKey HKCR "*\shell\CodeNotary sign"
  DeleteRegKey /ifempty HKCU "SOFTWARE\CodeNotary"
  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\CodeNotary"  
 
SectionEnd
 
;Function that calls a messagebox when installation finished correctly
Function .onInstSuccess
  MessageBox MB_OK "You have successfully installed CodeNotary vcn. Open the vcn icon in your startmenu and type vcn.exe to start"
FunctionEnd
 
 
Function un.onUninstSuccess
  MessageBox MB_OK "You have successfully uninstalled CodeNotary vcn."
FunctionEnd
 
