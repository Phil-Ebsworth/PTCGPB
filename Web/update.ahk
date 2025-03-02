; update.ahk

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

