version = Arturos PTCGP Bot
#SingleInstance, force
CoordMode, Mouse, Screen
SetTitleMatchMode, 3

#Include utils.ahk
#Include Web\web.ahk
#Include json\json.ahk
#Include Gui\gui.ahk

; If not running as admin, restart as admin
runAdmin()
; Print the licence box
printLicenceBox()
; Check for updates
CheckForUpdate()
KillADBProcesses()
; Create or open the JSON files
InitializeJsonFile() 
; Initialize the GUI    
writeGUI()
; show the GUI
Gui, Show, , %localVersion% PTCGPB Bot Setup [Non-Commercial 4.0 International License] ;'
Return

~+F7::ExitApp
