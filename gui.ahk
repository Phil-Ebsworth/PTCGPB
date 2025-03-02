; gui.ahk

global FriendID
; Create the main GUI for selecting number of instances
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
