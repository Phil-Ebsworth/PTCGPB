#Include %A_ScriptDir%\Include\Gdip_All.ahk
#Include %A_ScriptDir%\Include\Gdip_Imagesearch.ahk
#Include %A_ScriptDir%\worker\packs.ahk
#Include %A_ScriptDir%\worker\friends.ahk
#Include %A_ScriptDir%\worker\images.ahk
#Include %A_ScriptDir%\worker\account.ahk
#Include %A_ScriptDir%\worker\adb.ahk
#Include %A_ScriptDir%\worker\json.ahk
#Include %A_ScriptDir%\worker\window.ahk
#Include %A_ScriptDir%\tutorial.ahk
#Include %A_ScriptDir%\worker\aktions.ahk
#Include %A_ScriptDir%\worker\utils.ahk
#SingleInstance on
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetBatchLines, -1
SetTitleMatchMode, 3
CoordMode, Pixel, Screen
#NoEnv

; Allocate and hide the console window to reduce flashing
DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")

global winTitle, changeDate, failSafe, openPack, Delay, failSafeTime, StartSkipTime, Columns, failSafe, adbPort, scriptName, adbShell, adbPath, GPTest, StatusText, defaultLanguage, setSpeed, jsonFileName, pauseToggle, SelectedMonitorIndex, swipeSpeed, godPack, scaleParam, discordUserId, discordWebhookURL, deleteMethod, packs, FriendID, friendIDs, Instances, username, friendCode, stopToggle, friended, runMain, showStatus, injectMethod, packMethod, loadDir, loadedAccount, nukeAccount, TrainerCheck, FullArtCheck, RainbowCheck, dateChange, foundGP, foundTS, friendsAdded, minStars, PseudoGodPack, Palkia, Dialga, Mew, Pikachu, Charizard, Mewtwo, packArray, CrownCheck, ImmersiveCheck, slowMotion, screenShot, accountFile, invalid, starCount, gpFound, foundTS
scriptName := StrReplace(A_ScriptName, ".ahk")
winTitle := scriptName
foundGP := false
injectMethod := false
pauseToggle := false
showStatus := true
friended := false
dateChange := false
jsonFileName := A_ScriptDir . "\..\json\Packs.json"

getsettings()

pokemonList := ["Palkia", "Dialga", "Mew", "Pikachu", "Charizard", "Mewtwo", "Arceus"]

packArray := []  ; Initialize an empty array

Loop, % pokemonList.MaxIndex()  ; Loop through the array
{
    pokemon := pokemonList[A_Index]  ; Get the variable name as a string
    if (%pokemon%)  ; Dereference the variable using %pokemon%
        packArray.push(pokemon)  ; Add the name to packArray
}

changeDate := getChangeDateTime() ; get server reset time

if(heartBeat)
	IniWrite, 1, %A_ScriptDir%\..\HeartBeat.ini, HeartBeat, Instance%scriptName%

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
Sleep, % scriptName * 1000
; Attempt to connect to ADB
ConnectAdb()

if (InStr(defaultLanguage, "100")) {
	scaleParam := 287
} else {
	scaleParam := 277
}

resetWindows()

createOverlay()

Loop {
	Randmax := packArray.Length()
	Random, rand, 1, Randmax
	openPack := packArray[rand]
	friended := false
	IniWrite, 1, %A_ScriptDir%\..\HeartBeat.ini, HeartBeat, Instance%scriptName%
	FormatTime, CurrentTime,, HHmm

	StartTime := changeDate - 45 ; 12:55 AM2355
	EndTime := changeDate + 5 ; 1:01 AM

	; Adjust for crossing midnight
	if (StartTime < 0)
		StartTime += 2400
	if (EndTime >= 2400)
		EndTime -= 2400

	Random, randomTime, 3, 7

	While(((CurrentTime - StartTime >= 0) && (CurrentTime - StartTime <= randomTime)) || ((EndTime - CurrentTime >= 0) && (EndTime - CurrentTime <= randomTime)))
	{
		CreateStatusMessage("I need a break... Sleeping until " . changeDate + randomTime . " `nto avoid being kicked out from the date change")
		FormatTime, CurrentTime,, HHmm ; Update the current time after sleep
		Sleep, 5000
		dateChange := true
	}
	if(dateChange)
		createAccountList(scriptName)
	FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
	if(setSpeed = 3)
		FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
	else
		FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
	Delay(1)
	adbClick(41, 296)
	Delay(1)
	packs := 0

	if(!injectMethod || !loadedAccount)
		DoTutorial()

	if(deleteMethod = "5 Pack" || packMethod)
		if(!loadedAccount)
			wonderPicked := DoWonderPick()

	friendsAdded := AddFriends()
	SelectPack("First")
	PackOpening()

	if(packMethod) {
		friendsAdded := AddFriends(true)
		SelectPack()
	}

	PackOpening()

	if(!injectMethod || !loadedAccount)
		HourglassOpening() ;deletemethod check in here at the start

	if(wonderPicked) {
		friendsAdded := AddFriends(true)
		SelectPack("HGPack")
		PackOpening()
		if(packMethod) {
			friendsAdded := AddFriends(true)
			SelectPack("HGPack")
			PackOpening()
		}
		else {
			HourglassOpening(true)
		}
	}

	if(nukeAccount && !injectMethod)
		menuDelete()
	else
		RemoveFriends()

	if(injectMethod)
		loadedAccount := loadAccount()

	if(!injectMethod || !loadedAccount) {
		if(!nukeAccount) {
			saveAccount("All")
			restartGameInstance("New Run", false)
		}
	}

	CreateStatusMessage("New Run")
	rerolls++
	if(!loadedAccount)
		if(deleteMethod = "5 Pack" || packMethod)
			packs := 5
	AppendToJsonFile(packs)
	totalSeconds := Round((A_TickCount - rerollTime) / 1000) ; Total time in seconds
	avgtotalSeconds := Round(totalSeconds / rerolls) ; Total time in seconds
	minutes := Floor(avgtotalSeconds / 60) ; Total minutes
	seconds := Mod(avgtotalSeconds, 60) ; Remaining seconds within the minute
	mminutes := Floor(totalSeconds / 60) ; Total minutes
	sseconds := Mod(totalSeconds, 60) ; Remaining seconds within the minute
	CreateStatusMessage("Avg: " . minutes . "m " . seconds . "s Runs: " . rerolls, 25, 0, 510)
	LogToFile("Packs: " . packs . " Total time: " . mminutes . "m " . sseconds . "s Avg: " . minutes . "m " . seconds . "s Runs: " . rerolls)
	if(stopToggle)
		ExitApp
}
return


/*
^e::
	msgbox ss
	pToken := Gdip_Startup()
	Screenshot()
return
*/
