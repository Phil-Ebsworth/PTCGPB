; initialize.ahk

githubUser := "Arturo-1212"
repoName := "PTCGPB"
localVersion := "v6.3.13"
scriptFolder := A_ScriptDir
zipPath := A_Temp . "\update.zip"
extractPath := A_Temp . "\update"

; Function to create or select the JSON file
InitializeJsonFile() {
	global jsonFileName
	fileName := A_ScriptDir . "\json\Packs.json"
	if FileExist(fileName)
		FileDelete fileName
	FileAppend [] fileName  ; Write an empty JSON array
	totalFile := A_ScriptDir . "\json\total.json"
	backupFile := A_ScriptDir . "\json\total-backup.json"
	if FileExist(totalFile) ; Check if the file exists
	{
		FileCopy, %totalFile%, %backupFile%, 1 ; Copy source file to target
		if (ErrorLevel)
			MsgBox, Failed to create %backupFile%. Ensure permissions and paths are correct.
	}
	FileDelete, %totalFile%
	packsFile := A_ScriptDir . "\json\Packs.json"
	backupFile := A_ScriptDir . "\json\Packs-backup.json"
	if FileExist(packsFile) ; Check if the file exists
	{
		FileCopy, %packsFile%, %backupFile%, 1 ; Copy source file to target
		if (ErrorLevel)
			MsgBox, Failed to create %backupFile%. Ensure permissions and paths are correct.
	}
	jsonFileName := fileName
}

; Function to append a time and variable pair to the JSON file
AppendToJsonFile(value) {
    global variableValue := value
    global jsonContent := FileRead jsonFileName
	if (jsonFileName = "") {
        MsgBox "JSON file not initialized. Call InitializeJsonFile() first."
        return
    }

    jsonContent := RTrim(jsonContent, "]") ; Remove trailing bracket
    if (jsonContent != "[")
        jsonContent .= ","
    jsonContent .= "{""time"": """ A_Now """, ""variable"": " variableValue "}]"

    FileAppend jsonContent jsonFileName
	return jsonFileName
}

; Function to sum all variable values in the JSON file
SumVariablesInJsonFile() {
	jsonContent := FileRead jsonFileName

	if (jsonContent = "") {
		return 0
	}

	; Parse the JSON and calculate the sum
	sum := 0
	; Clean and parse JSON content
	jsonContent := StrReplace(jsonContent, "[", "") ; Remove starting bracket
	jsonContent := StrReplace(jsonContent, "]", "") ; Remove ending bracket
	Loop, Parse, jsonContent, {, }
	{
		; Match each variable value
		if (RegExMatch(A_LoopField, """variable"":\s*(-?\d+)", match)) {
			sum += match1
		}
	}

	; Write the total sum to a file called "total.json"

	if(sum > 0) {
		totalFile := A_ScriptDir . "\json\total.json"
		totalContent := "{""total_sum"": " sum "}"
		FileDelete totalFile
		FileAppend totalContent totalFile
	}

	return sum
}

; Existing function to extract value from JSON
ExtractJSONValue(json, key1, key2:="", ext:="") {
	value := ""
	json := StrReplace(json, """", "")
	lines := StrSplit(json, ",")

	Loop, % lines.MaxIndex()
	{
		if InStr(lines[A_Index], key1 ":") {
			; Take everything after the first colon as the value
			value := SubStr(lines[A_Index], InStr(lines[A_Index], ":") + 1)
			if (key2 != "")
			{
				if InStr(lines[A_Index+1], key2 ":") && InStr(lines[A_Index+1], ext)
					value := SubStr(lines[A_Index+1], InStr(lines[A_Index+1], ":") + 1)
			}
			break
		}
	}
	return Trim(value)
}

CheckForUpdate() {
	global githubUser, repoName, localVersion, zipPath, extractPath, scriptFolder
	url := "https://api.github.com/repos/" githubUser "/" repoName "/releases/latest"

	response := HttpGet(url)
	if !response
	{
		MsgBox "Failed to fetch release info."
		return
	}
	latestReleaseBody := FixFormat(ExtractJSONValue(response, "body"))
	latestVersion := ExtractJSONValue(response, "tag_name")
	zipDownloadURL := ExtractJSONValue(response, "zipball_url")
	Clipboard := latestReleaseBody
	if (zipDownloadURL = "" || !InStr(zipDownloadURL, "http"))
	{
		MsgBox, Failed to find the ZIP download URL in the release.
		return
	}

	if (latestVersion = "")
	{
		MsgBox, Failed to retrieve version info.
		return
	}

	if (VersionCompare(latestVersion, localVersion) > 0)
	{
		; Get release notes from the JSON (ensure this is populated earlier in the script)
		releaseNotes := latestReleaseBody  ; Assuming `latestReleaseBody` contains the release notes

		; Show a message box asking if the user wants to download
		MsgBox, 4, Update Available %latestVersion%, %releaseNotes%`n`nDo you want to download the latest version?

		; If the user clicks Yes (return value 6)
		IfMsgBox, Yes
		{
			MsgBox, 64, Downloading..., Downloading the latest version...

			; Proceed with downloading the update
			URLDownloadToFile, %zipDownloadURL%, %zipPath%
			if ErrorLevel
			{
				MsgBox, Failed to download update.
				return
			}
			else {
				MsgBox, Download complete. Extracting...

				; Create a temporary folder for extraction
				tempExtractPath := A_Temp "\PTCGPB_Temp"
				FileCreateDir, %tempExtractPath%

				; Extract the ZIP file into the temporary folder
				RunWait, powershell -Command "Expand-Archive -Path '%zipPath%' -DestinationPath '%tempExtractPath%' -Force",, Hide

				; Check if extraction was successful
				if !FileExist(tempExtractPath)
				{
					MsgBox, Failed to extract the update.
					return
				}

				; Get the first subfolder in the extracted folder
				Loop, Files, %tempExtractPath%\*, D
				{
					extractedFolder := A_LoopFileFullPath
					break
				}

				; Check if a subfolder was found and move its contents recursively to the script folder
				if (extractedFolder)
				{
					MoveFilesRecursively(extractedFolder, scriptFolder)

					; Clean up the temporary extraction folder
					FileRemoveDir, %tempExtractPath%, 1
					MsgBox, Update installed. Restarting...
					Reload
				}
				else
				{
					MsgBox, Failed to find the extracted contents.
					return
				}
			}
		}
		else
		{
			MsgBox, The update was canceled.
			return
		}
	}
	else
	{
		MsgBox, You are running the latest version (%localVersion%).
	}
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

HttpGet(url) {
	http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	http.Open("GET", url, false)
	http.Send()
	return http.ResponseText
}