; gui.ahk

#include GUI\aktions.ahk
#include GUI\messages.ahk
#include Gui\settings.ahk

global FriendID
global waitTime, Delay, Instances, instanceStartDelay, swipeSpeed,
global folderPath
global discordWebhookURL, discordUserId, heartBeat, heartBeatWebhookURL, heartBeatName
global Columns, godPack
global defaultLanguage, SelectedMonitorIndex, deleteMethod, runMain, nukeAccount, packMethod
global TrainerCheck, FullArtCheck, RainbowCheck, CrownCheck, ImmersiveCheck, PseudoGodPack
global minStars, slowMotion
global Palkia, Dialga, Arceus, Mew, Pikachu, Charizard, Mewtwo

writeGUI(){
    initGui()
    addFriendID()
    addRerollInstances()
    addGodpackSettings()
    addMethodSettings()
    addDiscordSettings()
    addPackSettings()
    addOtherPackSettings()
    addTimeSettings()
    addOtherSettings()
}



