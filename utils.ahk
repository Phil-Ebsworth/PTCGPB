; utils.ahk

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

FixFormat(text) {
	; Replace carriage return and newline with an actual line break
	text := StrReplace(text, "\r\n", "`n")  ; Replace \r\n with actual newlines
	text := StrReplace(text, "\n", "`n")    ; Replace \n with newlines

	; Remove unnecessary backslashes before other characters like "player" and "None"
	text := StrReplace(text, "\player", "player")   ; Example: removing backslashes around words
	text := StrReplace(text, "\None", "None")       ; Remove backslash around "None"
	text := StrReplace(text, "\Welcome", "Welcome") ; Removing \ before "Welcome"

	; Escape commas by replacing them with %2C (URL encoding)
	text := StrReplace(text, ",", "")

	return text
}

VersionCompare(v1, v2) {
	; Remove non-numeric characters (like 'alpha', 'beta')
	cleanV1 := RegExReplace(v1, "[^\d.]")
	cleanV2 := RegExReplace(v2, "[^\d.]")

	v1Parts := StrSplit(cleanV1, ".")
	v2Parts := StrSplit(cleanV2, ".")

	Loop, % Max(v1Parts.MaxIndex(), v2Parts.MaxIndex()) {
		num1 := v1Parts[A_Index] ? v1Parts[A_Index] : 0
		num2 := v2Parts[A_Index] ? v2Parts[A_Index] : 0
		if (num1 > num2)
			return 1
		if (num1 < num2)
			return -1
	}

	; If versions are numerically equal, check if one is an alpha version
	isV1Alpha := InStr(v1, "alpha") || InStr(v1, "beta")
	isV2Alpha := InStr(v2, "alpha") || InStr(v2, "beta")

	if (isV1Alpha && !isV2Alpha)
		return -1 ; Non-alpha version is newer
	if (!isV1Alpha && isV2Alpha)
		return 1 ; Alpha version is older

	return 0 ; Versions are equal
}

resetWindows(Title, SelectedMonitorIndex){
	global Columns, runMain
	RetryCount := 0
	MaxRetries := 10
	Loop
	{
		try {
			; Get monitor origin from index
			SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
			SysGet, Monitor, Monitor, %SelectedMonitorIndex%
			if(runMain) {
				if (Title = "Main") {
					instanceIndex := 1
				} else {
					instanceIndex := Title + 1
				}
			} else {
				instanceIndex := Title
			}
			rowHeight := 533  ; Adjust the height of each row
			currentRow := Floor((instanceIndex - 1) / Columns)
			y := currentRow * rowHeight
			x := Mod((instanceIndex - 1), Columns) * scaleParam
			WinMove, %Title%, , % (MonitorLeft + x), % (MonitorTop + y), scaleParam, 537
			break
		}
		catch {
			if (RetryCount > MaxRetries)
				Pause
		}
		Sleep, 1000
	}
	return true
}

CreateStatusMessage(Message, X := 0, Y := 80) {
	global PacksText, SelectedMonitorIndex, createdGUI, Instances
	MaxRetries := 10
	RetryCount := 0
	try {
		GuiName := 22
		SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
		SysGet, Monitor, Monitor, %SelectedMonitorIndex%
		X := MonitorLeft + X
		Y := MonitorTop + Y
		Gui %GuiName%:+LastFoundExist
		if WinExist() {
			GuiControl, , PacksText, %Message%
		} else {			OwnerWND := WinExist(1)
			if(!OwnerWND)
				Gui, %GuiName%:New, +ToolWindow -Caption
			else
				Gui, %GuiName%:New, +Owner%OwnerWND% +ToolWindow -Caption
			Gui, %GuiName%:Margin, 2, 2  ; Set margin for the GUI
			Gui, %GuiName%:Font, s8  ; Set the font size to 8 (adjust as needed)
			Gui, %GuiName%:Add, Text, vPacksText, %Message%
			Gui, %GuiName%:Show, NoActivate x%X% y%Y%, NoActivate %GuiName%
		}
	}
}

runAdmin() {
	if not A_IsAdmin{
		; Relaunch script with admin rights
		Run *RunAs "%A_ScriptFullPath%"
		ExitApp
	}
}

KillADBProcesses() {
	; Use AHK's Process command to close adb.exe
	Process, Close, adb.exe
	; Fallback to taskkill for robustness
	RunWait, %ComSpec% /c taskkill /IM adb.exe /F /T,, Hide
}

MoveFilesRecursively(srcFolder, destFolder) {
	; Loop through all files and subfolders in the source folder
	Loop, Files, % srcFolder . "\*", R
	{
		; Get the relative path of the file/folder from the srcFolder
		relativePath := SubStr(A_LoopFileFullPath, StrLen(srcFolder) + 2)

		; Create the corresponding destination path
		destPath := destFolder . "\" . relativePath

		; If it's a directory, create it in the destination folder
		if (A_LoopIsDir)
		{
			; Ensure the directory exists, if not, create it
			FileCreateDir, % destPath
		}
		else
		{
			if ((relativePath = "ids.txt" && FileExist(destPath)) || (relativePath = "usernames.txt" && FileExist(destPath)) || (relativePath = "discord.txt" && FileExist(destPath))) {
                continue
            }
			if (relativePath = "usernames.txt" && FileExist(destPath)) {
                continue
            }
			if (relativePath = "usernames.txt" && FileExist(destPath)) {
                continue
            }
			; If it's a file, move it to the destination folder
			; Ensure the directory exists before moving the file
			FileCreateDir, % SubStr(destPath, 1, InStr(destPath, "\", 0, 0) - 1)
			FileMove, % A_LoopFileFullPath, % destPath, 1
		}
	}
}