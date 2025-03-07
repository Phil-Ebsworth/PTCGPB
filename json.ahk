; json.ahk

global Instances, instanceStartDelay, jsonFileName, PacksText, runMain, scaleParam

global jsonFileName := ""

InitializeJsonFile() {
	global jsonFileName
	fileName := A_ScriptDir . "\json\Packs.json"
    totalFile := A_ScriptDir . "\json\total.json"
    totalbackupFile := A_ScriptDir . "\json\total-backup.json"
    packsFile := A_ScriptDir . "\json\Packs.json"
    packsbackupFile := A_ScriptDir . "\json\Packs-backup.json"
    if FileExist(totalFile) ; Check if the file exists
        {
            FileCopy, %totalFile%, %totalbackupFile%, 1 ; Copy source file to target
            if (ErrorLevel)
                MsgBox, Failed to create %backupFile%. Ensure permissions and paths are correct.
        }
        FileDelete, %totalFile%
    if FileExist(packsFile) ; Check if the file exists
        {
            FileCopy, %packsFile%, %packsbackupFile%, 1 ; Copy source file to target
            if (ErrorLevel)
                MsgBox, Failed to create %backupFile%. Ensure permissions and paths are correct.
        }
	if FileExist(fileName)
		FileDelete, %fileName%
	if !FileExist(fileName) {
		; Create a new file with an empty JSON array
		FileAppend, [], %fileName%  ; Write an empty JSON array
		jsonFileName := fileName
		return
	}
}





; Function to append a time and variable pair to the JSON file
AppendToJsonFile(variableValue) {
	global jsonFileName
	if (jsonFileName = "") {
		MsgBox, JSON file not initialized. Call InitializeJsonFile() first.
		return
	}

	; Read the current content of the JSON file
	FileRead, jsonContent, %jsonFileName%
	if (jsonContent = "") {
		jsonContent := "[]"
	}

	; Parse and modify the JSON content
	jsonContent := SubStr(jsonContent, 1, StrLen(jsonContent) - 1) ; Remove trailing bracket
	if (jsonContent != "[")
		jsonContent .= ","
	jsonContent .= "{""time"": """ A_Now """, ""variable"": " variableValue "}]"

	; Write the updated JSON back to the file
	FileDelete, %jsonFileName%
	FileAppend, %jsonContent%, %jsonFileName%
}

; Function to sum all variable values in the JSON file
SumVariablesInJsonFile() {
	global jsonFileName
	if (jsonFileName = "") {
		return
	}

	; Read the file content
	FileRead, jsonContent, %jsonFileName%
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
		FileDelete, %totalFile%
		FileAppend, %totalContent%, %totalFile%
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