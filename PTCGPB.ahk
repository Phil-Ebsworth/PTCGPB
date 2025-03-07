version = Arturos PTCGP Bot
#SingleInstance, force
CoordMode, Mouse, Screen
SetTitleMatchMode, 3

githubUser := "Arturo-1212"
repoName := "PTCGPB"
localVersion := "v6.3.16"
scriptFolder := A_ScriptDir
zipPath := A_Temp . "\update.zip"
extractPath := A_Temp . "\update"

#Include json.ahk
#Include window.ahk
#Include web.ahk
#Include utils.ahk
#Include gui.ahk

if not A_IsAdmin
{
	; Relaunch script with admin rights
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
}

MsgBox, 64, The project is now licensed under CC BY-NC 4.0, The original intention of this project was not for it to be used for paid services even those disguised as 'donations.' I hope people respect my wishes and those of the community. `nThe project is now licensed under CC BY-NC 4.0, which allows you to use, modify, and share the software only for non-commercial purposes. Commercial use, including using the software to provide paid services or selling it (even if donations are involved), is not allowed under this license. The new license applies to this and all future releases.

CheckForUpdate()

KillADBProcesses()

InitializeJsonFile() ; Create or open the JSON file

Init_gui_value()

buildGUI()

~+F7::ExitApp
