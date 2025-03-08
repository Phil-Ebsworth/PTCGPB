; adb.ahk

initializeAdbShell() {
	global adbShell, adbPath, adbPort
	RetryCount := 0
	MaxRetries := 10
	BackoffTime := 1000  ; Initial backoff time in milliseconds
	MaxBackoff := 5000   ; Prevent excessive waiting

	Loop {
		try {
			if (!adbShell || adbShell.Status != 0) {
				adbShell := ""  ; Reset before reattempting

				; Validate adbPath and adbPort
				if (!FileExist(adbPath)) {
					throw "ADB path is invalid: " . adbPath
				}
				if (adbPort < 0 || adbPort > 65535) {
					throw "ADB port is invalid: " . adbPort
				}

				; Attempt to start adb shell
				adbShell := ComObjCreate("WScript.Shell").Exec(adbPath . " -s 127.0.0.1:" . adbPort . " shell")

				; Ensure adbShell is running before sending 'su'
				Sleep, 500
				if (adbShell.Status != 0) {
					throw "Failed to start ADB shell."
				}

				adbShell.StdIn.WriteLine("su")
			}

			; If adbShell is running, break loop
			if (adbShell.Status = 0) {
				break
			}
		} catch e {
			RetryCount++
			LogToFile("ADB Shell Error: " . e.message)

			if (RetryCount >= MaxRetries) {
				CreateStatusMessage("Failed to connect to shell after multiple attempts: " . e.message)
				Pause
			}
		}

		Sleep, BackoffTime
		BackoffTime := Min(BackoffTime + 1000, MaxBackoff)  ; Limit backoff time
	}
}

ConnectAdb() {
	global adbPath, adbPort, StatusText
	MaxRetries := 5
	RetryCount := 0
	connected := false
	ip := "127.0.0.1:" . adbPort ; Specify the connection IP:port

	CreateStatusMessage("Connecting to ADB...")

	Loop %MaxRetries% {
		; Attempt to connect using CmdRet
		connectionResult := CmdRet(adbPath . " connect " . ip)

		; Check for successful connection in the output
		if InStr(connectionResult, "connected to " . ip) {
			connected := true
			CreateStatusMessage("ADB connected successfully.")
			return true
		} else {
			RetryCount++
			CreateStatusMessage("ADB connection failed. Retrying (" . RetryCount . "/" . MaxRetries . ").")
			Sleep, 2000
		}
	}

	if !connected {
		CreateStatusMessage("Failed to connect to ADB after multiple retries. Please check your emulator and port settings.")
		Reload
	}
}

findAdbPorts(baseFolder := "C:\Program Files\Netease") {
	global adbPorts, winTitle, scriptName
	; Initialize variables
	adbPorts := 0  ; Create an empty associative array for adbPorts
	mumuFolder = %baseFolder%\MuMuPlayerGlobal-12.0\vms\*
	if !FileExist(mumuFolder)
		mumuFolder = %baseFolder%\MuMu Player 12\vms\*

	if !FileExist(mumuFolder){
		MsgBox, 16, , Double check your folder path! It should be the one that contains the MuMuPlayer 12 folder! `nDefault is just C:\Program Files\Netease
		ExitApp
	}
	; Loop through all directories in the base folder
	Loop, Files, %mumuFolder%, D  ; D flag to include directories only
	{
		folder := A_LoopFileFullPath
		configFolder := folder "\configs"  ; The config folder inside each directory

		; Check if config folder exists
		IfExist, %configFolder%
		{
			; Define paths to vm_config.json and extra_config.json
			vmConfigFile := configFolder "\vm_config.json"
			extraConfigFile := configFolder "\extra_config.json"

			; Check if vm_config.json exists and read adb host port
			IfExist, %vmConfigFile%
			{
				FileRead, vmConfigContent, %vmConfigFile%
				; Parse the JSON for adb host port
				RegExMatch(vmConfigContent, """host_port"":\s*""(\d+)""", adbHostPort)
				adbPort := adbHostPort1  ; Capture the adb host port value
			}

			; Check if extra_config.json exists and read playerName
			IfExist, %extraConfigFile%
			{
				FileRead, extraConfigContent, %extraConfigFile%
				; Parse the JSON for playerName
				RegExMatch(extraConfigContent, """playerName"":\s*""(.*?)""", playerName)
				if(playerName1 = scriptName) {
					return adbPort
				}
			}
		}
	}
}

waitadb() {
	adbShell.StdIn.WriteLine("echo done")
	while !adbShell.StdOut.AtEndOfStream
	{
		line := adbShell.StdOut.ReadLine()
		if (line = "done")
			break
		Sleep, 50
	}
}


; adbClick(X, Y) {
	; global adbShell, setSpeed, adbPath, adbPort
	; initializeAdbShell()
	; X := Round(X / 277 * 540)
	; Y := Round((Y - 44) / 489 * 960)
	; adbShell.StdIn.WriteLine("input tap " X " " Y)
; }

adbClick(X, Y) {
    global adbShell
    static clickCommands := Object()
    static convX := 540/277, convY := 960/489, offset := -44

    key := X << 16 | Y 

    if (!clickCommands.HasKey(key)) {
        clickCommands[key] := Format("input tap {} {}"
            , Round(X * convX)
            , Round((Y + offset) * convY))
    }
    adbShell.StdIn.WriteLine(clickCommands[key])
}

ControlClick(X, Y) {
	global winTitle
	ControlClick, x%X% y%Y%, %winTitle%
}

adbInput(input) {
	global adbShell, adbPath, adbPort
	;initializeAdbShell()
	Delay(3)
	adbShell.StdIn.WriteLine("input text " . input )
	Delay(3)
}

adbInputEvent(event) {
	global adbShell, adbPath, adbPort
	;initializeAdbShell()
	adbShell.StdIn.WriteLine("input keyevent " . event)
}

adbSwipeUp() {
	global adbShell, adbPath, adbPort
	;initializeAdbShell()
	adbShell.StdIn.WriteLine("input swipe 309 816 309 355 60")
	waitadb()
}

adbSwipe() {
	global adbShell, setSpeed, swipeSpeed, adbPath, adbPort
	;initializeAdbShell()
	X1 := 35
	Y1 := 327
	X2 := 267
	Y2 := 327
	X1 := Round(X1 / 277 * 535)
	Y1 := Round((Y1 - 44) / 489 * 960)
	X2 := Round(X2 / 277 * 535)
	Y2 := Round((Y2 - 44) / 489 * 960)

	adbShell.StdIn.WriteLine("input swipe " . X1 . " " . Y1 . " " . X2 . " " . Y2 . " " . swipeSpeed)
	waitadb()
}

Screenshot(filename := "Valid") {
	global adbShell, adbPath, packs
	SetWorkingDir %A_ScriptDir%  ; Ensures the working directory is the script's directory

	; Define folder and file paths
	screenshotsDir := A_ScriptDir "\..\Screenshots"
	if !FileExist(screenshotsDir)
		FileCreateDir, %screenshotsDir%

	; File path for saving the screenshot locally
	screenshotFile := screenshotsDir "\" . A_Now . "_" . winTitle . "_" . filename . "_" . packs . "_packs.png"
	;pBitmap := from_window(WinExist(winTitle))
	pBitmap := Gdip_CloneBitmapArea(from_window(WinExist(winTitle)), 18, 175, 240, 227)

	Gdip_SaveBitmapToFile(pBitmap, screenshotFile)

	Gdip_DisposeImage(pBitmap)
	return screenshotFile
}