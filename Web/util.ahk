; util.ahk

DownloadFile(url, filename) {
	url := url  ; Change to your hosted .txt URL "https://pastebin.com/raw/vYxsiqSs"
	localPath = %A_ScriptDir%\%filename% ; Change to the folder you want to save the file

	URLDownloadToFile, %url%, %localPath%

	; if ErrorLevel
	; MsgBox, Download failed!
	; else
	; MsgBox, File downloaded successfully!

}

HttpGet(url) {
	http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	http.Open("GET", url, false)
	http.Send()
	return http.ResponseText
}