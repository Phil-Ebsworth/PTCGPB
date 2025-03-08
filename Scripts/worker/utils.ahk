; utils.ahk

getsettings(){
    global FriendID, waitTime, Delay, folderPath, discordWebhookURL, discordUserId, Columns, godPack, Instances, defaultLanguage, SelectedMonitorIndex, swipeSpeed, deleteMethod, runMain, heartBeat, heartBeatWebhookURL, heartBeatName, nukeAccount, packMethod, TrainerCheck, FullArtCheck, RainbowCheck, CrownCheck, ImmersiveCheck, PseudoGodPack, minStars, Palkia, Dialga, Arceus, Mew, Pikachu, Charizard, Mewtwo, slowMotion

    IniRead, FriendID, %A_ScriptDir%\..\Settings.ini, UserSettings, FriendID
    IniRead, waitTime, %A_ScriptDir%\..\Settings.ini, UserSettings, waitTime, 5
    IniRead, Delay, %A_ScriptDir%\..\Settings.ini, UserSettings, Delay, 250
    IniRead, folderPath, %A_ScriptDir%\..\Settings.ini, UserSettings, folderPath, C:\Program Files\Netease
    IniRead, discordWebhookURL, %A_ScriptDir%\..\Settings.ini, UserSettings, discordWebhookURL, ""
    IniRead, discordUserId, %A_ScriptDir%\..\Settings.ini, UserSettings, discordUserId, ""
    IniRead, Columns, %A_ScriptDir%\..\Settings.ini, UserSettings, Columns, 5
    IniRead, godPack, %A_ScriptDir%\..\Settings.ini, UserSettings, godPack, Continue
    IniRead, Instances, %A_ScriptDir%\..\Settings.ini, UserSettings, Instances, 1
    IniRead, defaultLanguage, %A_ScriptDir%\..\Settings.ini, UserSettings, defaultLanguage, Scale125
    IniRead, SelectedMonitorIndex, %A_ScriptDir%\..\Settings.ini, UserSettings, SelectedMonitorIndex, 1
    IniRead, swipeSpeed, %A_ScriptDir%\..\Settings.ini, UserSettings, swipeSpeed, 300
    IniRead, deleteMethod, %A_ScriptDir%\..\Settings.ini, UserSettings, deleteMethod, 3 Pack
    IniRead, runMain, %A_ScriptDir%\..\Settings.ini, UserSettings, runMain, 1
    IniRead, heartBeat, %A_ScriptDir%\..\Settings.ini, UserSettings, heartBeat, 0
    IniRead, heartBeatWebhookURL, %A_ScriptDir%\..\Settings.ini, UserSettings, heartBeatWebhookURL, ""
    IniRead, heartBeatName, %A_ScriptDir%\..\Settings.ini, UserSettings, heartBeatName, ""
    IniRead, nukeAccount, %A_ScriptDir%\..\Settings.ini, UserSettings, nukeAccount, 0
    IniRead, packMethod, %A_ScriptDir%\..\Settings.ini, UserSettings, packMethod, 0
    IniRead, TrainerCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, TrainerCheck, 0
    IniRead, FullArtCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, FullArtCheck, 0
    IniRead, RainbowCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, RainbowCheck, 0
    IniRead, CrownCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, CrownCheck, 0
    IniRead, ImmersiveCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, ImmersiveCheck, 0
    IniRead, PseudoGodPack, %A_ScriptDir%\..\Settings.ini, UserSettings, PseudoGodPack, 0
    IniRead, minStars, %A_ScriptDir%\..\Settings.ini, UserSettings, minStars, 0
    IniRead, Palkia, %A_ScriptDir%\..\Settings.ini, UserSettings, Palkia, 0
    IniRead, Dialga, %A_ScriptDir%\..\Settings.ini, UserSettings, Dialga, 0
    IniRead, Arceus, %A_ScriptDir%\..\Settings.ini, UserSettings, Arceus, 1
    IniRead, Mew, %A_ScriptDir%\..\Settings.ini, UserSettings, Mew, 0
    IniRead, Pikachu, %A_ScriptDir%\..\Settings.ini, UserSettings, Pikachu, 0
    IniRead, Charizard, %A_ScriptDir%\..\Settings.ini, UserSettings, Charizard, 0
    IniRead, Mewtwo, %A_ScriptDir%\..\Settings.ini, UserSettings, Mewtwo, 0
    IniRead, slowMotion, %A_ScriptDir%\..\Settings.ini, UserSettings, slowMotion, 0
}
MonthToDays(year, month) {
    static DaysInMonths := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    days := 0
    Loop, % month - 1 {
        days += DaysInMonths[A_Index]
    }
    if (month > 2 && IsLeapYear(year))
        days += 1
    return days
}

IsLeapYear(year) {
    return (Mod(year, 4) = 0 && Mod(year, 100) != 0) || Mod(year, 400) = 0
}

Delay(n) {
	global Delay
	msTime := Delay * n
	Sleep, msTime
}

createAccountList(instance) {
	currentDate := A_Now
	year := SubStr(currentDate, 1, 4)
	month := SubStr(currentDate, 5, 2)
	day := SubStr(currentDate, 7, 2)

	daysSinceBase := (year - 1900) * 365 + Floor((year - 1900) / 4)
	daysSinceBase += MonthToDays(year, month)
	daysSinceBase += day

	remainder := Mod(daysSinceBase, 3)

	saveDir := A_ScriptDir "\..\Accounts\Saved\" . remainder . "\" . instance
	outputTxt := saveDir . "\list.txt"

	if FileExist(outputTxt) {
		FileGetTime, fileTime, %outputTxt%, M  ; Get last modified time
		timeDiff := A_Now - fileTime  ; Calculate time difference
		if (timeDiff > 86400)  ; 24 hours in seconds (60 * 60 * 24)
			FileDelete, %outputTxt%
	}
	if (!FileExist(outputTxt)) {
		Loop, %saveDir%\*.xml {
			xml := saveDir . "\" . A_LoopFileName
			FileGetTime, fileTime, %xml%, M
			timeDiff := A_Now - fileTime  ; Calculate time difference
			if (timeDiff > 86400) {  ; 24 hours in seconds (60 * 60 * 24) 
				FileAppend, % A_LoopFileName "`n", %outputTxt%  ; Append file path to output.txt\
			}
		}
	}
}

getChangeDateTime() {
	; Get system timezone bias and determine local time for 1 AM EST

	; Retrieve timezone information from Windows registry
	RegRead, TimeBias, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation, Bias
	RegRead, DltBias, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation, ActiveTimeBias

	; Convert registry values to integers
	Bias := TimeBias + 0
	DltBias := DltBias + 0

	; Determine if Daylight Saving Time (DST) is active
	IsDST := (Bias != DltBias) ? 1 : 0

	; EST is UTC-5 (300 minutes offset)
	EST_Offset := 300

	; Use the correct local offset (DST or Standard)
	Local_Offset := (IsDST) ? DltBias : Bias

	; Convert 1 AM EST to UTC (UTC = EST + 5 hours)
	UTC_Time := 1 + EST_Offset / 60  ; 06:00 UTC

	; Convert UTC to local time
	Local_Time := UTC_Time - (Local_Offset / 60)

	; Round to ensure we get whole numbers
	Local_Time := Floor(Local_Time)

	; Handle 24-hour wrap-around
	If (Local_Time < 0)
		Local_Time += 24
	Else If (Local_Time >= 24)
		Local_Time -= 24

	; Format output as HHMM
	FormattedTime := (Local_Time < 10 ? "0" : "") . Local_Time . "00"

	Return FormattedTime
}

DownloadFile(url, filename) {
	url := url  ; Change to your hosted .txt URL "https://pastebin.com/raw/vYxsiqSs"
	localPath = %A_ScriptDir%\..\%filename% ; Change to the folder you want to save the file
	errored := false
	try {
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", url, true)
		whr.Send()
		whr.WaitForResponse()
		ids := whr.ResponseText
	} catch {
		errored := true
	}
	if(!errored) {
		FileDelete, %localPath%
		FileAppend, %ids%, %localPath%
	}
}

ReadFile(filename, numbers := false) {
	global FriendID
	if(InStr(FriendID, "https")) {
		DownloadFile(FriendID, "ids.txt")
		Delay(1)
	}
	FileRead, content, %A_ScriptDir%\..\%filename%.txt

	if (!content)
		return false

	values := []
	for _, val in StrSplit(Trim(content), "`n") {
		cleanVal := RegExReplace(val, "[^a-zA-Z0-9]") ; Remove non-alphanumeric characters
		if (cleanVal != "")
			values.Push(cleanVal)
	}

	return values.MaxIndex() ? values : false
}

LogToDiscord(message, screenshotFile := "", ping := false, xmlFile := "", screenshotFile2 := "") {
	global discordUserId, discordWebhookURL, friendCode
	discordPing := "<@" . discordUserId . "> "
	discordFriends := ReadFile("discord")

	if(ping != false && discordFriends) {
		for index, value in discordFriends {
			if(value = discordUserId)
				continue
			discordPing .= "<@" . value . "> "
		}
	}

	if (discordWebhookURL != "") {
		MaxRetries := 10
		RetryCount := 0
		Loop {
			try {
				if(screenshotFile != "" && screenshotFile2 != "" && FileExist(screenshotFile) && FileExist(screenshotFile2))
				{
					; Send the image using curl
					curlCommand := "curl -k "
						. "-F ""payload_json={\""content\"":\""" . discordPing . message . "\""};type=application/json;charset=UTF-8"" "
						. "-F ""file1=@" . screenshotFile . """ "
						. "-F ""file2=@" . screenshotFile2 . """ "
						. discordWebhookURL
					RunWait, %curlCommand%,, Hide
				} else if (screenshotFile != "") {
					; Check if the file exists
					if (FileExist(screenshotFile)) {
						; Send the image using curl
						curlCommand := "curl -k "
							. "-F ""payload_json={\""content\"":\""" . discordPing . message . "\""};type=application/json;charset=UTF-8"" "
							. "-F ""file=@" . screenshotFile . """ "
							. discordWebhookURL
						RunWait, %curlCommand%,, Hide
					}
				}
				else {
					curlCommand := "curl -k "
						. "-F ""payload_json={\""content\"":\""" . discordPing . message . "\""};type=application/json;charset=UTF-8"" " . discordWebhookURL
					RunWait, %curlCommand%,, Hide
				}
				break
			}
			catch {
				RetryCount++
				if (RetryCount >= MaxRetries) {
					CreateStatusMessage("Failed to send discord message.")
					break
				}
				Sleep, 250
			}
			sleep, 250
		}
	}
}

LogToFile(message, logFile := "") {
	global scriptName
	if(logFile = "") {
		return ;step logs no longer needed and i'm too lazy to go through the script and remove them atm...
		logFile := A_ScriptDir . "\..\Logs\Logs" . scriptName . ".txt"
	}
	else
		logFile := A_ScriptDir . "\..\Logs\" . logFile
	FormatTime, readableTime, %A_Now%, MMMM dd, yyyy HH:mm:ss
	FileAppend, % "[" readableTime "] " message "`n", %logFile%
}

CreateStatusMessage(Message, GuiName := 50, X := 0, Y := 80) {
	global scriptName, winTitle, StatusText, showStatus
	if(!showStatus) {
		return
	}
	try {
		GuiName := GuiName+scriptName
		WinGetPos, xpos, ypos, Width, Height, %winTitle%
		X := X + xpos + 5
		Y := Y + ypos
		if(!X)
			X := 0
		if(!Y)
			Y := 0

		; Create a new GUI with the given name, position, and message
		Gui, %GuiName%:New, -AlwaysOnTop +ToolWindow -Caption
		Gui, %GuiName%:Margin, 2, 2  ; Set margin for the GUI
		Gui, %GuiName%:Font, s8  ; Set the font size to 8 (adjust as needed)
		Gui, %GuiName%:Add, Text, vStatusText, %Message%
		Gui, %GuiName%:Show, NoActivate x%X% y%Y% AutoSize, NoActivate %GuiName%
	}
}

ToggleStop()
{
	global stopToggle, friended
	CreateStatusMessage("Stopping script at the end of the run...")
	stopToggle := true
	if(!friended)
		ExitApp
}

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

ToggleStatusMessages() {
	if(showStatus) {
		showStatus := False
	}
	else
		showStatus := True
}

bboxAndPause(X1, Y1, X2, Y2, doPause := False) {
	BoxWidth := X2-X1
	BoxHeight := Y2-Y1
	; Create a GUI
	Gui, BoundingBox:+AlwaysOnTop +ToolWindow -Caption +E0x20
	Gui, BoundingBox:Color, 123456
	Gui, BoundingBox:+LastFound  ; Make the GUI window the last found window for use by the line below. (straght from documentation)
	WinSet, TransColor, 123456 ; Makes that specific color transparent in the gui

	; Create the borders and show
	Gui, BoundingBox:Add, Progress, x0 y0 w%BoxWidth% h2 BackgroundRed
	Gui, BoundingBox:Add, Progress, x0 y0 w2 h%BoxHeight% BackgroundRed
	Gui, BoundingBox:Add, Progress, x%BoxWidth% y0 w2 h%BoxHeight% BackgroundRed
	Gui, BoundingBox:Add, Progress, x0 y%BoxHeight% w%BoxWidth% h2 BackgroundRed
	Gui, BoundingBox:Show, x%X1% y%Y1% NoActivate
	Sleep, 100

	if (doPause) {
		Pause
	}

	if GetKeyState("F4", "P") {
		Pause
	}

	Gui, BoundingBox:Destroy
}

CmdRet(sCmd, callBackFuncObj := "", encoding := "")
{
	static HANDLE_FLAG_INHERIT := 0x00000001, flags := HANDLE_FLAG_INHERIT
		, STARTF_USESTDHANDLES := 0x100, CREATE_NO_WINDOW := 0x08000000

   (encoding = "" && encoding := "cp" . DllCall("GetOEMCP", "UInt"))
   DllCall("CreatePipe", "PtrP", hPipeRead, "PtrP", hPipeWrite, "Ptr", 0, "UInt", 0)
   DllCall("SetHandleInformation", "Ptr", hPipeWrite, "UInt", flags, "UInt", HANDLE_FLAG_INHERIT)

   VarSetCapacity(STARTUPINFO , siSize :=    A_PtrSize*4 + 4*8 + A_PtrSize*5, 0)
   NumPut(siSize              , STARTUPINFO)
   NumPut(STARTF_USESTDHANDLES, STARTUPINFO, A_PtrSize*4 + 4*7)
   NumPut(hPipeWrite          , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*3)
   NumPut(hPipeWrite          , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*4)

   VarSetCapacity(PROCESS_INFORMATION, A_PtrSize*2 + 4*2, 0)

   if !DllCall("CreateProcess", "Ptr", 0, "Str", sCmd, "Ptr", 0, "Ptr", 0, "UInt", true, "UInt", CREATE_NO_WINDOW
                              , "Ptr", 0, "Ptr", 0, "Ptr", &STARTUPINFO, "Ptr", &PROCESS_INFORMATION)
   {
      DllCall("CloseHandle", "Ptr", hPipeRead)
      DllCall("CloseHandle", "Ptr", hPipeWrite)
      throw "CreateProcess is failed"
   }
   DllCall("CloseHandle", "Ptr", hPipeWrite)
   VarSetCapacity(sTemp, 4096), nSize := 0
   while DllCall("ReadFile", "Ptr", hPipeRead, "Ptr", &sTemp, "UInt", 4096, "UIntP", nSize, "UInt", 0) {
      sOutput .= stdOut := StrGet(&sTemp, nSize, encoding)
      ( callBackFuncObj && callBackFuncObj.Call(stdOut) )
   }
   DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION))
   DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, A_PtrSize))
   DllCall("CloseHandle", "Ptr", hPipeRead)
   Return sOutput
}

GetNeedle(Path) {
	static NeedleBitmaps := Object()
	if (NeedleBitmaps.HasKey(Path)) {
		return NeedleBitmaps[Path]
	} else {
		pNeedle := Gdip_CreateBitmapFromFile(Path)
		NeedleBitmaps[Path] := pNeedle
		return pNeedle
	}
}
