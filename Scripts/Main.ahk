#Include %A_ScriptDir%\Include\Gdip_All.ahk
#Include %A_ScriptDir%\Include\Gdip_Imagesearch.ahk
#include %A_ScriptDir%\function.ahk
#include json\json.ahk
#Include util.ahk
#SingleInstance on
;SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
;SetWinDelay, -1
;SetControlDelay, -1
SetBatchLines, -1
SetTitleMatchMode, 3
CoordMode, Pixel, Screen

; Allocate and hide the console window to reduce flashing
DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")

global winTitle, changeDate, failSafe, openPack, Delay, failSafeTime, StartSkipTime, Columns, failSafe, adbPort, scriptName, adbShell, adbPath, GPTest, StatusText, defaultLanguage, setSpeed, jsonFileName, pauseToggle, SelectedMonitorIndex, swipeSpeed, godPack, scaleParam, discordUserId, discordWebhookURL, skipInvalidGP, deleteXML, packs, FriendID, AddFriend, Instances, showStatus

deleteAccount := false
scriptName := StrReplace(A_ScriptName, ".ahk")
winTitle := scriptName
pauseToggle := false
showStatus := true
jsonFileName := A_ScriptDir . "\..\json\Packs.json"
IniRead, FriendID, %A_ScriptDir%\..\Settings.ini, UserSettings, FriendID
IniRead, Instances, %A_ScriptDir%\..\Settings.ini, UserSettings, Instances
IniRead, Delay, %A_ScriptDir%\..\Settings.ini, UserSettings, Delay, 250
IniRead, folderPath, %A_ScriptDir%\..\Settings.ini, UserSettings, folderPath, C:\Program Files\Netease
IniRead, Variation, %A_ScriptDir%\..\Settings.ini, UserSettings, Variation, 20
IniRead, Columns, %A_ScriptDir%\..\Settings.ini, UserSettings, Columns, 5
IniRead, openPack, %A_ScriptDir%\..\Settings.ini, UserSettings, openPack, 1
IniRead, setSpeed, %A_ScriptDir%\..\Settings.ini, UserSettings, setSpeed, 2x
IniRead, defaultLanguage, %A_ScriptDir%\..\Settings.ini, UserSettings, defaultLanguage, Scale125
IniRead, SelectedMonitorIndex, %A_ScriptDir%\..\Settings.ini, UserSettings, SelectedMonitorIndex, 1:
IniRead, swipeSpeed, %A_ScriptDir%\..\Settings.ini, UserSettings, swipeSpeed, 350
IniRead, skipInvalidGP, %A_ScriptDir%\..\Settings.ini, UserSettings, skipInvalidGP, No
IniRead, godPack, %A_ScriptDir%\..\Settings.ini, UserSettings, godPack, Continue
IniRead, discordWebhookURL, %A_ScriptDir%\..\Settings.ini, UserSettings, discordWebhookURL, ""
IniRead, discordUserId, %A_ScriptDir%\..\Settings.ini, UserSettings, discordUserId, ""
IniRead, deleteMethod, %A_ScriptDir%\..\Settings.ini, UserSettings, deleteMethod, Hoard
IniRead, sendXML, %A_ScriptDir%\..\Settings.ini, UserSettings, sendXML, 0
IniRead, heartBeat, %A_ScriptDir%\..\Settings.ini, UserSettings, heartBeat, 1
if(heartBeat)
	IniWrite, 1, %A_ScriptDir%\..\HeartBeat.ini, HeartBeat, Main

adbPort := findAdbPorts(folderPath)

adbPath := folderPath . "\MuMuPlayerGlobal-12.0\shell\adb.exe"

if !FileExist(adbPath) ;if international mumu file path isn't found look for chinese domestic path
	adbPath := folderPath . "\MuMu Player 12\shell\adb.exe"

if !FileExist(adbPath)
	MsgBox Double check your folder path! It should be the one that contains the MuMuPlayer 12 folder! `nDefault is just C:\Program Files\Netease

if(!adbPort) {
	Msgbox, Invalid port... Check the common issues section in the readme/github guide.
	ExitApp
}

; connect adb
instanceSleep := scriptName * 1000
Sleep, %instanceSleep%

; Attempt to connect to ADB
ConnectAdb()

if (InStr(defaultLanguage, "100")) {
	scaleParam := 287
} else {
	scaleParam := 277
}

rerollTime := A_TickCount

initializeAdbShell()
restartGameInstance("Initializing bot...", false)
pToken := Gdip_Startup()

if(heartBeat)
	IniWrite, 1, %A_ScriptDir%\..\HeartBeat.ini, HeartBeat, Main
FindImageAndClick(120, 500, 155, 530, , "Social", 143, 518, 1000, 150)
firstRun := true
Loop {
	if(heartBeat)
		IniWrite, 1, %A_ScriptDir%\..\HeartBeat.ini, HeartBeat, Main
	Sleep, %Delay%
	FindImageAndClick(120, 500, 155, 530, , "Social", 143, 518, 1000, 30)
	FindImageAndClick(226, 100, 270, 135, , "Add", 38, 460, 500)
	FindImageAndClick(170, 450, 195, 480, , "Approve", 228, 464)
	if(firstRun) {
		Sleep, 1000
		adbClick(205, 510)
		Sleep, 1000
		adbClick(210, 372)
		firstRun := false
	}
	done := false
	Loop 3 {
		Sleep, %Delay%
		if(FindOrLoseImage(225, 195, 250, 215, , "Pending", 0)) {
			failSafe := A_TickCount
			failSafeTime := 0
			Loop {
				Sleep, %Delay%
				clickButton := FindOrLoseImage(75, 340, 195, 530, 80, "Button", 0, failSafeTime) ;looking for ok button in case an invite is withdrawn
				if(FindOrLoseImage(123, 110, 162, 127, , "99", 0, failSafeTime)) {
					done := true
					break
				} else if(FindOrLoseImage(80, 170, 120, 195, , "player", 0, failSafeTime)) {
					Sleep, %Delay%
					adbClick(210, 210)
					Sleep, 1000
				} else if(FindOrLoseImage(225, 195, 250, 220, , "Pending", 0, failSafeTime)) {
					adbClick(245, 210)
				} else if(FindOrLoseImage(186, 496, 206, 518, , "Accept", 0, failSafeTime)) {
					done := true
					break
				} else if(clickButton) {
					StringSplit, pos, clickButton, `,  ; Split at ", "
					Sleep, 1000
					if(FindImageAndClick(190, 195, 215, 220, , "DeleteFriend", pos1, pos2, 4000)) {
						Sleep, %Delay%
						adbClick(210, 210)
					}
				}
				failSafeTime := (A_TickCount - failSafe) // 1000
				CreateStatusMessage("Failsafe " . failSafeTime "/180 seconds")
			}
		}
		if(done || fullList)
			break
	}
}
return

; Pause Script
PauseScript:
	CreateStatusMessage("Pausing...")
	Pause, On
return

; Resume Script
ResumeScript:
	CreateStatusMessage("Resuming...")
	Pause, Off
	StartSkipTime := A_TickCount ;reset stuck timers
	failSafe := A_TickCount
return

; Stop Script
StopScript:
	CreateStatusMessage("Stopping script...")
ExitApp
return

ShowStatusMessages:
	ToggleStatusMessages()
return

ReloadScript:
	Reload
return

TestScript:
	ToggleTestScript()
return

ToggleTestScript()
{
	global GPTest
	if(!GPTest) {
		CreateStatusMessage("In GP Test Mode")
		GPTest := true
	}
	else {
		CreateStatusMessage("Exiting GP Test Mode")
		;Winset, Alwaysontop, On, %winTitle%
		GPTest := false
	}
}

FriendAdded()
{
	global AddFriend
	AddFriend++
}

~+F5::Reload
~+F6::Pause
~+F7::ExitApp
~+F8::ToggleStatusMessages()

; ^e::
; msgbox ss
; pToken := Gdip_Startup()
; Screenshot()
; return
