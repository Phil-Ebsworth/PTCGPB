; json.ahk

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