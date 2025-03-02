; aktions.ahk
#Include Web\update.ahk

CheckForUpdates() {
	CheckForUpdate()
	return
}

discordSettings() {
    Gui, Submit, NoHide

	if (heartBeat) {
		GuiControl, Show, heartBeatName
		GuiControl, Show, heartBeatWebhookURL
		GuiControl, Show, hbName
		GuiControl, Show, hbURL
	}
	else {
		GuiControl, Hide, heartBeatName
		GuiControl, Hide, heartBeatWebhookURL
		GuiControl, Hide, hbName
		GuiControl, Hide, hbURL
	}
return
}

deleteSettings() {
    Gui, Submit, NoHide
	;GuiControlGet, deleteMethod,, deleteMethod

	if(InStr(deleteMethod, "Inject")) {
		GuiControl, Hide, nukeAccount
		nukeAccount = false
	}
	else
		GuiControl, Show, nukeAccount
    return
}

ArrangeWindows() {
    GuiControlGet, runMain,, runMain
    GuiControlGet, Instances,, Instances
    GuiControlGet, Columns,, Columns
    GuiControlGet, SelectedMonitorIndex,, SelectedMonitorIndex
    if (runMain) {
        resetWindows("Main", SelectedMonitorIndex)
        sleep, 10
    }
    Loop %Instances% {
        resetWindows(A_Index, SelectedMonitorIndex)
        sleep, 10
    }
    return
}

OpenLink() {
    Run, https://buymeacoffee.com/aarturoo
    return
}

OpenDiscord() {
    Run, https://discord.gg/C9Nyf7P4sT
    return
}

Start() {
    Gui, Submit  ; Collect the input values from the first page
    Instances := Instances  ; Directly reference the "Instances" variable

    ; Create the second page dynamically based on the number of instances
    Gui, Destroy ; Close the first page

    IniWrite, %FriendID%, Settings.ini, UserSettings, FriendID
    IniWrite, %waitTime%, Settings.ini, UserSettings, waitTime
    IniWrite, %Delay%, Settings.ini, UserSettings, Delay
    IniWrite, %folderPath%, Settings.ini, UserSettings, folderPath
    IniWrite, %discordWebhookURL%, Settings.ini, UserSettings, discordWebhookURL
    IniWrite, %discordUserId%, Settings.ini, UserSettings, discordUserId
    IniWrite, %Columns%, Settings.ini, UserSettings, Columns
    IniWrite, %openPack%, Settings.ini, UserSettings, openPack
    IniWrite, %godPack%, Settings.ini, UserSettings, godPack
    IniWrite, %Instances%, Settings.ini, UserSettings, Instances
    IniWrite, %instanceStartDelay%, Settings.ini, UserSettings, instanceStartDelay
    ;IniWrite, %setSpeed%, Settings.ini, UserSettings, setSpeed
    IniWrite, %defaultLanguage%, Settings.ini, UserSettings, defaultLanguage
    IniWrite, %SelectedMonitorIndex%, Settings.ini, UserSettings, SelectedMonitorIndex
    IniWrite, %swipeSpeed%, Settings.ini, UserSettings, swipeSpeed
    IniWrite, %deleteMethod%, Settings.ini, UserSettings, deleteMethod
    IniWrite, %runMain%, Settings.ini, UserSettings, runMain
    IniWrite, %heartBeat%, Settings.ini, UserSettings, heartBeat
    IniWrite, %heartBeatWebhookURL%, Settings.ini, UserSettings, heartBeatWebhookURL
    IniWrite, %heartBeatName%, Settings.ini, UserSettings, heartBeatName
    IniWrite, %nukeAccount%, Settings.ini, UserSettings, nukeAccount
    IniWrite, %packMethod%, Settings.ini, UserSettings, packMethod
    IniWrite, %TrainerCheck%, Settings.ini, UserSettings, TrainerCheck
    IniWrite, %FullArtCheck%, Settings.ini, UserSettings, FullArtCheck
    IniWrite, %RainbowCheck%, Settings.ini, UserSettings, RainbowCheck
    IniWrite, %CrownCheck%, Settings.ini, UserSettings, CrownCheck
    IniWrite, %ImmersiveCheck%, Settings.ini, UserSettings, ImmersiveCheck
    IniWrite, %PseudoGodPack%, Settings.ini, UserSettings, PseudoGodPack
    IniWrite, %minStars%, Settings.ini, UserSettings, minStars
    IniWrite, %Palkia%, Settings.ini, UserSettings, Palkia
    IniWrite, %Dialga%, Settings.ini, UserSettings, Dialga
    IniWrite, %Arceus%, Settings.ini, UserSettings, Arceus
    IniWrite, %Mew%, Settings.ini, UserSettings, Mew
    IniWrite, %Pikachu%, Settings.ini, UserSettings, Pikachu
    IniWrite, %Charizard%, Settings.ini, UserSettings, Charizard
    IniWrite, %Mewtwo%, Settings.ini, UserSettings, Mewtwo
    IniWrite, %slowMotion%, Settings.ini, UserSettings, slowMotion

    ; Run main before instances to account for instance start delay
    if (runMain) {
        FileName := "Scripts\Main.ahk"
        Run, %FileName%
    }

    ; Loop to process each instance
    Loop, %Instances%
    {
        if (A_Index != 1) {
            SourceFile := "Scripts\1.ahk" ; Path to the source .ahk file
            TargetFolder := "Scripts\" ; Path to the target folder
            TargetFile := TargetFolder . A_Index . ".ahk" ; Generate target file path
            if(Instances > 1) {
                FileDelete, %TargetFile%
                FileCopy, %SourceFile%, %TargetFile%, 1 ; Copy source file to target
            }
            if (ErrorLevel)
                MsgBox, Failed to create %TargetFile%. Ensure permissions and paths are correct.
        }

        FileName := "Scripts\" . A_Index . ".ahk"
        Command := FileName

        if (A_Index != 1 && instanceStartDelay > 0) {
            instanceStartDelayMS := instanceStartDelay * 1000
            Sleep, instanceStartDelayMS
        }

        Run, %Command%
    }

    if(inStr(FriendID, "https"))
        DownloadFile(FriendID, "ids.txt")
    SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
    SysGet, Monitor, Monitor, %SelectedMonitorIndex%
    rerollTime := A_TickCount
    Loop {
        Sleep, 30000
        ; Sum all variable values and write to total.json
        total := SumVariablesInJsonFile()
        totalSeconds := Round((A_TickCount - rerollTime) / 1000) ; Total time in seconds
        mminutes := Floor(totalSeconds / 60)
        if(total = 0)
            total := "0                             "
        packStatus := "Time: " . mminutes . "m Packs: " . total
        CreateStatusMessage(packStatus, 287, 490)
        if(heartBeat)
            if((A_Index = 1 || (Mod(A_Index, 60) = 0))) {
                onlineAHK := "Online: "
                offlineAHK := "Offline: "
                Online := []
                if(runMain) {
                    IniRead, value, HeartBeat.ini, HeartBeat, Main
                    if(value)
                        onlineAHK := "Online: Main, "
                    else
                        offlineAHK := "Offline: Main, "
                    IniWrite, 0, HeartBeat.ini, HeartBeat, Main
                }
                Loop %Instances% {
                    IniRead, value, HeartBeat.ini, HeartBeat, Instance%A_Index%
                    if(value)
                        Online.push(1)
                    else
                        Online.Push(0)
                    IniWrite, 0, HeartBeat.ini, HeartBeat, Instance%A_Index%
                }
                for index, value in Online {
                    if(index = Online.MaxIndex())
                        commaSeparate := "."
                    else
                        commaSeparate := ", "
                    if(value)
                        onlineAHK .= A_Index . commaSeparate
                    else
                        offlineAHK .= A_Index . commaSeparate
                }
                if(offlineAHK = "Offline: ")
                    offlineAHK := "Offline: none."
                if(onlineAHK = "Online: ")
                    onlineAHK := "Online: none."

                discMessage := "\n" . onlineAHK . "\n" . offlineAHK . "\n" . packStatus
                if(heartBeatName)
                    discordUserID := heartBeatName
                LogToDiscord(discMessage, , discordUserID)
            }
    }
    return
}

GuiClose() {
    ExitApp
}