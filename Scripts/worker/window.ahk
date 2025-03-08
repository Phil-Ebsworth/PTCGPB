; window.ahk

resetWindows(){
	global Columns, winTitle, SelectedMonitorIndex, scaleParam, FriendID
	CreateStatusMessage("Arranging window positions and sizes")
	RetryCount := 0
	MaxRetries := 10
	Loop
	{
		try {
			; Get monitor origin from index
			SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
			SysGet, Monitor, Monitor, %SelectedMonitorIndex%
			Title := winTitle
			rowHeight := 533  ; Height of each row

			if(runMain) {
				; Calculate currentRow
				if (winTitle <= Columns - 1) {
					currentRow := 0  ; First row has (Columns - 1) windows
				} else {
					; For rows after the first, adjust calculation
					adjustedWinTitle := winTitle - (Columns - 1)
					currentRow := Floor((adjustedWinTitle - 1) / Columns) + 1
				}

				; Calculate x position
				if (currentRow == 0) {
					x := winTitle * scaleParam  ; First row uses (Columns - 1) columns
				} else {
					adjustedWinTitle := winTitle - (Columns - 1)
					x := Mod(adjustedWinTitle - 1, Columns) * scaleParam  ; Subsequent rows use full Columns
				}
			} else {
				currentRow := Floor((winTitle - 1) / Columns)
				x := Mod((winTitle - 1), Columns) * scaleParam
			}

			y := currentRow * rowHeight

			; Move the window
			WinMove, %Title%, , % (MonitorLeft + x), % (MonitorTop + y), scaleParam, 537
			break
		}
		catch {
			if (RetryCount > MaxRetries) {
				CreateStatusMessage("Pausing. Can't find window " . winTitle)
				Pause
			}
			RetryCount++
		}
		Sleep, 1000
	}
	return true
}

from_window(ByRef image) {
	; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517

	; Get the handle to the window.
	image := (hwnd := WinExist(image)) ? hwnd : image

	; Restore the window if minimized! Must be visible for capture.
	if DllCall("IsIconic", "ptr", image)
		DllCall("ShowWindow", "ptr", image, "int", 4)

	; Get the width and height of the client window.
	VarSetCapacity(Rect, 16) ; sizeof(RECT) = 16
	DllCall("GetClientRect", "ptr", image, "ptr", &Rect)
		, width  := NumGet(Rect, 8, "int")
		, height := NumGet(Rect, 12, "int")

	; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
	hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
	VarSetCapacity(bi, 40, 0)                ; sizeof(bi) = 40
		, NumPut(       40, bi,  0,   "uint") ; Size
		, NumPut(    width, bi,  4,   "uint") ; Width
		, NumPut(  -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
		, NumPut(        1, bi, 12, "ushort") ; Planes
		, NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel
		, NumPut(        0, bi, 16,   "uint") ; Compression = BI_RGB
		, NumPut(        3, bi, 20,   "uint") ; Quality setting (3 = low quality, no anti-aliasing)
	hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits:=0, "ptr", 0, "uint", 0, "ptr")
	obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

	; Print the window onto the hBitmap using an undocumented flag. https://stackoverflow.com/a/40042587
	DllCall("PrintWindow", "ptr", image, "ptr", hdc, "uint", 0x3) ; PW_CLIENTONLY | PW_RENDERFULLCONTENT
	; Additional info on how this is implemented: https://www.reddit.com/r/windows/comments/8ffr56/altprintscreen/

	; Convert the hBitmap to a Bitmap using a built in function as there is no transparency.
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hbm, "ptr", 0, "ptr*", pBitmap:=0)

	; Cleanup the hBitmap and device contexts.
	DllCall("SelectObject", "ptr", hdc, "ptr", obm)
	DllCall("DeleteObject", "ptr", hbm)
	DllCall("DeleteDC",	 "ptr", hdc)

	return pBitmap
}

createOverlay(){
    MaxRetries := 10
    RetryCount := 0
    Loop {
        try {
            WinGetPos, x, y, Width, Height, %winTitle%
            sleep, 2000
            ;Winset, Alwaysontop, On, %winTitle%
            OwnerWND := WinExist(winTitle)
            x4 := x + 5
            y4 := y + 44

            Gui, New, +Owner%OwnerWND% -AlwaysOnTop +ToolWindow -Caption
            Gui, Default
            Gui, Margin, 4, 4  ; Set margin for the GUI
            Gui, Font, s5 cGray Norm Bold, Segoe UI  ; Normal font for input labels
            Gui, Add, Button, x0 y0 w30 h25 gReloadScript, Reload  (Shift+F5)
            Gui, Add, Button, x40 y0 w30 h25 gPauseScript, Pause (Shift+F6)
            Gui, Add, Button, x80 y0 w40 h25 gResumeScript, Resume (Shift+F6)
            Gui, Add, Button, x120 y0 w30 h25 gStopScript, Stop (Shift+F7)
            Gui, Add, Button, x160 y0 w40 h25 gShowStatusMessages, Status (Shift+F8)
            Gui, Show, NoActivate x%x4% y%y4% AutoSize
            break
        }
        catch {
            RetryCount++
            if (RetryCount >= MaxRetries) {
                CreateStatusMessage("Failed to create button gui.")
                break
            }
            Sleep, 1000
        }
        Delay(1)
        CreateStatusMessage("Trying to create button gui...")
    }

    if (!godPack)
        godPack = 1
    else if (godPack = "Close")
        godPack = 1
    else if (godPack = "Pause")
        godPack = 2
    if (godPack = "Continue")
        godPack = 3

    if (!setSpeed)
        setSpeed = 1
    if (setSpeed = "2x")
        setSpeed := 1
    else if (setSpeed = "1x/2x")
        setSpeed := 2
    else if (setSpeed = "1x/3x")
        setSpeed := 3

    setSpeed := 3 ;always 1x/3x

    if(InStr(deleteMethod, "Inject"))
        injectMethod := true

    rerollTime := A_TickCount

    initializeAdbShell()

    createAccountList(scriptName)

    if(injectMethod) {
        loadedAccount := loadAccount()
        nukeAccount := false
    }

    if(!injectMethod || !loadedAccount)
        restartGameInstance("Initializing bot...", false)

    pToken := Gdip_Startup()
    packs := 0

}

; Pause Script
PauseScript:
	CreateStatusMessage("Pausing...")
	Pause, On
return

; Resume Script
ResumeScript:
	CreateStatusMessage("Resuming...")
	StartSkipTime := A_TickCount ;reset stuck timers
	failSafe := A_TickCount
	Pause, Off
return

; Stop Script
StopScript:
	ToggleStop()
return

ShowStatusMessages:
	ToggleStatusMessages()
return

ReloadScript:
	Reload
return

TestScript:
	ToggleTestScript()
return

~+F5::Reload
~+F6::Pause
~+F7::ToggleStop()
~+F8::ToggleStatusMessages()
;~F9::restartGameInstance("F9")
