; settings.ahk

initGui(){
    IniRead, FriendID, Settings.ini, UserSettings, FriendID
    IniRead, waitTime, Settings.ini, UserSettings, waitTime, 5
    IniRead, Delay, Settings.ini, UserSettings, Delay, 250
    IniRead, folderPath, Settings.ini, UserSettings, folderPath, C:\Program Files\Netease
    IniRead, discordWebhookURL, Settings.ini, UserSettings, discordWebhookURL, ""
    IniRead, discordUserId, Settings.ini, UserSettings, discordUserId, ""
    IniRead, Columns, Settings.ini, UserSettings, Columns, 5
    IniRead, godPack, Settings.ini, UserSettings, godPack, Continue
    IniRead, Instances, Settings.ini, UserSettings, Instances, 1
    IniRead, instanceStartDelay, Settings.ini, UserSettings, instanceStartDelay, 0
    IniRead, defaultLanguage, Settings.ini, UserSettings, defaultLanguage, Scale125
    IniRead, SelectedMonitorIndex, Settings.ini, UserSettings, SelectedMonitorIndex, 1
    IniRead, swipeSpeed, Settings.ini, UserSettings, swipeSpeed, 300
    IniRead, deleteMethod, Settings.ini, UserSettings, deleteMethod, 3 Pack
    IniRead, runMain, Settings.ini, UserSettings, runMain, 1
    IniRead, heartBeat, Settings.ini, UserSettings, heartBeat, 0
    IniRead, heartBeatWebhookURL, Settings.ini, UserSettings, heartBeatWebhookURL, ""
    IniRead, heartBeatName, Settings.ini, UserSettings, heartBeatName, ""
    IniRead, nukeAccount, Settings.ini, UserSettings, nukeAccount, 0
    IniRead, packMethod, Settings.ini, UserSettings, packMethod, 0
    IniRead, TrainerCheck, Settings.ini, UserSettings, TrainerCheck, 0
    IniRead, FullArtCheck, Settings.ini, UserSettings, FullArtCheck, 0
    IniRead, RainbowCheck, Settings.ini, UserSettings, RainbowCheck, 0
    IniRead, CrownCheck, Settings.ini, UserSettings, CrownCheck, 0
    IniRead, ImmersiveCheck, Settings.ini, UserSettings, ImmersiveCheck, 0
    IniRead, PseudoGodPack, Settings.ini, UserSettings, PseudoGodPack, 0
    IniRead, minStars, Settings.ini, UserSettings, minStars, 0
    IniRead, Palkia, Settings.ini, UserSettings, Palkia, 0
    IniRead, Dialga, Settings.ini, UserSettings, Dialga, 0
    IniRead, Arceus, Settings.ini, UserSettings, Arceus, 1
    IniRead, Mew, Settings.ini, UserSettings, Mew, 0
    IniRead, Pikachu, Settings.ini, UserSettings, Pikachu, 0
    IniRead, Charizard, Settings.ini, UserSettings, Charizard, 0
    IniRead, Mewtwo, Settings.ini, UserSettings, Mewtwo, 0
    IniRead, slowMotion, Settings.ini, UserSettings, slowMotion, 0
}

addFriendID(){
    Gui, Add, Text, x10 y10, Friend ID:
    ; Add input controls
    if(FriendID = "ERROR")
        FriendID =

    if(FriendID = )
        Gui, Add, Edit, vFriendID w120 x60 y8
    else
        Gui, Add, Edit, vFriendID w120 x60 y8 h18, %FriendID%
}

addRerollInstances(){
    Gui, Add, Text, x10 y30, Rerolling Instances:
    Gui, Add, Text, x30 y50, Instances:
    Gui, Add, Edit, vInstances w25 x90 y45 h18, %Instances%
    Gui, Add, Text, x30 y72, Start Delay:
    Gui, Add, Edit, vinstanceStartDelay w25 x90 y67 h18, %instanceStartDelay%
    Gui, Add, Text, x30 y95, Columns:
    Gui, Add, Edit, Columns w25 x90 y90 h18, %Columns%
    if(runMain)
        Gui, Add, Checkbox, Checked vrunMain x30 y115, Run Main
    else
        Gui, Add, Checkbox, vrunMain x30 y115, Run Main
}

addGodpackSettings(){
    Gui, Add, Text, x10 y135, God Pack Settings:
    Gui, Add, Text, x30 y155, Min. 2 Stars:
    Gui, Add, Edit, cminStars w25 x90 y155 h18, %minStars%
}

addMethodSettings(){
    Gui, Add, Text, x10 y180, Method:

    ; Pack selection logic
    if (deleteMethod = "5 Pack") {
        defaultDelete := 1
    } else if (deleteMethod = "3 Pack") {
        defaultDelete := 2
    } else if (deleteMethod = "Inject") {
        defaultDelete := 3
    }

    Gui, Add, DropDownList, vdeleteMethod gdeleteSettings choose%defaultDelete% x55 y178 w60, 5 Pack|3 Pack|Inject

    if(packMethod)
        Gui, Add, Checkbox, Checked vpackMethod x30 y205, 1 Pack Method
    else
        Gui, Add, Checkbox, vpackMethod x30 y205, 1 Pack Method

    if(nukeAccount)
        Gui, Add, Checkbox, Checked vnukeAccount x30 y225, Menu Delete Account
    else
        Gui, Add, Checkbox, vnukeAccount x30 y225, Menu Delete Account
}

addDiscordSettings(){
    if(StrLen(discordUserID) < 3)
        discordUserID =
    if(StrLen(discordWebhookURL) < 3)
        discordWebhookURL =
    
    Gui, Add, Text, x10 y245, Discord Settings:
    Gui, Add, Text, x30 y265, Discord ID:
    Gui, Add, Edit, vdiscordUserId w100 x90 y260 h18, %discordUserId%
    Gui, Add, Text, x30 y290, Discord Webhook URL:
    Gui, Add, Edit, vdiscordWebhookURL h20 w100 x150 y285 h18, %discordWebhookURL%
    
    if(StrLen(heartBeatName) < 3)
        heartBeatName =
    if(StrLen(heartBeatWebhookURL) < 3)
        heartBeatWebhookURL =
    if(heartBeat) {
        Gui, Add, Checkbox, Checked vheartBeat x30 y315 gdiscordSettings, Discord Heartbeat
        Gui, Add, Text, hbName x30 y335, Name:
        Gui, Add, Edit, vheartBeatName w50 x70 y330 h18, %heartBeatName%
        Gui, Add, Text, hbURL x30 y360, Webhook URL:
        Gui, Add, Edit, vheartBeatWebhookURL h20 w100 x110 y355 h18, %heartBeatWebhookURL%
    } else {
        Gui, Add, Checkbox, vheartBeat x30 y315 gdiscordSettings, Discord Heartbeat
        Gui, Add, Text, hbName x30 y335 Hidden, Name:
        Gui, Add, Edit, vheartBeatName w50 x70 y330 h18 Hidden, %heartBeatName%
        Gui, Add, Text, hbURL x30 y360 Hidden, Webhook URL:
        Gui, Add, Edit, vheartBeatWebhookURL h20 w100 x110 y355 h18 Hidden, %heartBeatWebhookURL%
    }
}

addPackSettings(){
    Gui, Add, Text, x275 y10, Choose Pack(s):

    packs := ["Arceus", "Palkia", "Dialga", "Pikachu", "Charizard", "Mewtwo", "Mew"]
    xPos := 295
    yPos := 30

    for index, pack in packs {
        if (%pack%) {
            Gui, Add, Checkbox, Checked v%pack% x%xPos% y%yPos%, %pack%
        } else {
            Gui, Add, Checkbox, v%pack% x%xPos% y%yPos%, %pack%
        }
        yPos += 20
        if (index == 2) {
            xPos := 350
            yPos := 30
        } else if (index == 5) {
            xPos := 410
            yPos := 30
        }
    }
}

addOtherPackSettings(){
    Gui, Add, Text, x275 y90, Other Pack Detection Settings:

if(FullArtCheck)
	Gui, Add, Checkbox, Checked vFullArtCheck x295 y110, Single Full Art
else
	Gui, Add, Checkbox, vFullArtCheck x295 y110, Single Full Art

if(TrainerCheck)
	Gui, Add, Checkbox, Checked vTrainerCheck x295 y130, Single Trainer
else
	Gui, Add, Checkbox, vTrainerCheck x295 y130, Single Trainer

if(RainbowCheck)
	Gui, Add, Checkbox, Checked vRainbowCheck x295 y150, Single Rainbow
else
	Gui, Add, Checkbox, vRainbowCheck x295 y150, Single Rainbow

if(PseudoGodPack)
	Gui, Add, Checkbox, Checked vPseudoGodPack x392 y110, Double 2 Star
else
	Gui, Add, Checkbox, vPseudoGodPack x392 y110, Double 2 Star

if(CrownCheck)
	Gui, Add, Checkbox, Checked vCrownCheck x392 y130, Save Crowns
else
	Gui, Add, Checkbox, vCrownCheck x392 y130, Save Crowns

if(ImmersiveCheck)
	Gui, Add, Checkbox, Checked vImmersiveCheck x392 y150, Save Immersives
else
	Gui, Add, Checkbox, vImmersiveCheck x392 y150, Save Immersives

}

addTimeSettings(){
    Gui, Add, Text, x275 y170, Time Settings:
    Gui, Add, Text, x295 y190, Delay:
    Gui, Add, Edit, vDelay w35 x330 y190 h18, %Delay%
    Gui, Add, Text, x295 y210, Wait Time:
    Gui, Add, Edit, vwaitTime w25 x350 y210 h18, %waitTime%
    Gui, Add, Text, x295 y230, Swipe Speed:
    Gui, Add, Edit, vswipeSpeed w35 x365 y230 h18, %swipeSpeed%
}

addOtherSettings(){
    Gui, Add, Text, x275 y250, Other Settings:
    Gui, Add, Text, x295 y270, Monitor:
    ; Initialize monitor dropdown options
    SysGet, MonitorCount, MonitorCount
    MonitorOptions := ""
    Loop, %MonitorCount%
    {
        SysGet, MonitorName, MonitorName, %A_Index%
        SysGet, Monitor, Monitor, %A_Index%
        MonitorOptions .= (A_Index > 1 ? "|" : "") "" A_Index ": (" MonitorRight - MonitorLeft "x" MonitorBottom - MonitorTop ")"

    }
    SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
    Gui, Add, DropDownList, x335 y268 w90 vSelectedMonitorIndex Choose%SelectedMonitorIndex%, %MonitorOptions%
    Gui, Add, Text, x295 y290, Folder Path:
    Gui, Add, Edit, vfolderPath w100 x355 y290 h18, %folderPath%
    if(slowMotion)
        Gui, Add, Checkbox, Checked vslowMotion x295 y310, Base Game Compatibility
    else
        Gui, Add, Checkbox, vslowMotion x295 y310, Base Game Compatibility

    Gui, Add, Button, gOpenLink x15 y380 w120, Buy Me a Coffee <3
    Gui, Add, Button, gOpenDiscord x145 y380 w120, Join our Discord!
    Gui, Add, Button, gCheckForUpdates x275 y360 w120, Check for updates
    Gui, Add, Button, gArrangeWindows x275 y380 w120, Arrange Windows
    Gui, Add, Button, gStart x405 y380 w120, Start

    if (defaultLanguage = "Scale125") {
        defaultLang := 1
        scaleParam := 277
    } else if (defaultLanguage = "Scale100") {
        defaultLang := 2
        scaleParam := 287
    }
}