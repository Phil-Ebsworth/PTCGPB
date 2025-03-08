; account.ahk

loadAccount() {
	global adbShell, adbPath, adbPort, loadDir
	CreateStatusMessage("Loading account...")
	currentDate := A_Now
	year := SubStr(currentDate, 1, 4)
	month := SubStr(currentDate, 5, 2)
	day := SubStr(currentDate, 7, 2)

	daysSinceBase := (year - 1900) * 365 + Floor((year - 1900) / 4)
	daysSinceBase += MonthToDays(year, month)
	daysSinceBase += day

	remainder := Mod(daysSinceBase, 3)

	saveDir := A_ScriptDir "\..\Accounts\Saved\" . remainder . "\" . winTitle

	outputTxt := saveDir . "\list.txt"

	if FileExist(outputTxt) {
		FileRead, fileContent, %outputTxt%  ; Read entire file
		fileLines := StrSplit(fileContent, "`n", "`r")  ; Split into lines

		if (fileLines.MaxIndex() >= 1) {
			cycle := 0
			Loop {
				CreateStatusMessage("Making sure XML is > 24 hours old: " . cycle . " attempts.")
				loadDir := saveDir . "\" . fileLines[1]  ; Store the first line
				test := fileExist(loadDir)

				if(!InStr(loadDir, "xml"))
					return false
				newContent := ""
				Loop, % fileLines.MaxIndex() - 1  ; Start from the second line
					newContent .= fileLines[A_Index + 1] "`r`n"

				FileDelete, %outputTxt%  ; Delete old file
				FileAppend, %newContent%, %outputTxt%  ; Write back without the first line

				FileGetTime, fileTime, %loadDir%, M  ; Get last modified time
				timeDiff := A_Now - fileTime

				if (timeDiff > 86400)
					break
				cycle++
				Delay(1)
			}
		} else return false
	} else return false

		;initializeAdbShell()

	adbShell.StdIn.WriteLine("am force-stop jp.pokemon.pokemontcgp")

	RunWait, % adbPath . " -s 127.0.0.1:" . adbPort . " push " . loadDir . " /sdcard/deviceAccount.xml",, Hide

	Sleep, 500

	adbShell.StdIn.WriteLine("cp /sdcard/deviceAccount.xml /data/data/jp.pokemon.pokemontcgp/shared_prefs/deviceAccount:.xml")
	waitadb()
	adbShell.StdIn.WriteLine("rm /sdcard/deviceAccount.xml")
	waitadb()
	adbShell.StdIn.WriteLine("am start -n jp.pokemon.pokemontcgp/com.unity3d.player.UnityPlayerActivity")
	waitadb()
	Sleep, 1000
	return loadDir
}

saveAccount(file := "Valid") {
	global adbShell, adbPath, adbPort
	;initializeAdbShell()
	currentDate := A_Now
	year := SubStr(currentDate, 1, 4)
	month := SubStr(currentDate, 5, 2)
	day := SubStr(currentDate, 7, 2)

	daysSinceBase := (year - 1900) * 365 + Floor((year - 1900) / 4)
	daysSinceBase += MonthToDays(year, month)
	daysSinceBase += day

	remainder := Mod(daysSinceBase, 3)

	if (file = "All") {
		saveDir := A_ScriptDir "\..\Accounts\Saved\" . remainder . "\" . winTitle
		filePath := saveDir . "\" . A_Now . "_" . winTitle . ".xml"
	} else if(file = "Valid" || file = "Invalid") {
		saveDir := A_ScriptDir "\..\Accounts\GodPacks\"
		xmlFile := A_Now . "_" . winTitle . "_" . file . "_" . packs . "_packs.xml"
		filePath := saveDir . xmlFile
	} else {
		saveDir := A_ScriptDir "\..\Accounts\SpecificCards\"
		xmlFile := A_Now . "_" . winTitle . "_" . file . "_" . packs . "_packs.xml"
		filePath := saveDir . xmlFile
	}

	if !FileExist(saveDir) ; Check if the directory exists
		FileCreateDir, %saveDir% ; Create the directory if it doesn't exist

	count := 0
	Loop {
		CreateStatusMessage("Attempting to save account XML. " . count . "/10")

		adbShell.StdIn.WriteLine("cp /data/data/jp.pokemon.pokemontcgp/shared_prefs/deviceAccount:.xml /sdcard/deviceAccount.xml")
		waitadb()
		Sleep, 500

		RunWait, % adbPath . " -s 127.0.0.1:" . adbPort . " pull /sdcard/deviceAccount.xml """ . filePath,, Hide

		Sleep, 500

		FileGetSize, OutputVar, %filePath%

		if(OutputVar > 0)
			break

		if(count > 10 && file != "All") {
			CreateStatusMessage("Attempted to save the account XML`n10 times, but was unsuccesful.`nPausing...")
			LogToDiscord("Attempted to save account in " . scriptName . " but was unsuccessful. Pausing. You will need to manually extract.", Screenshot(), discordUserId)
			Pause, On
		} else if(count > 10) {
			LogToDiscord("Couldnt save this regular account skipping it.")
			break
		}
		count++
	}

	return xmlFile
}