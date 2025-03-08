; aktions.ahk

TradeTutorial() {
	if(FindOrLoseImage(100, 120, 175, 145, , "Trade", 0)) {
		FindImageAndClick(15, 455, 40, 475, , "Add2", 188, 449)
		Sleep, 1000
		FindImageAndClick(226, 100, 270, 135, , "Add", 38, 460, 500)
	}
	Delay(1)
}

LevelUp() {
	Leveled := FindOrLoseImage(100, 86, 167, 116, , "LevelUp", 0)
	if(Leveled) {
		clickButton := FindOrLoseImage(75, 340, 195, 530, 80, "Button", 0, failSafeTime)
		StringSplit, pos, clickButton, `,  ; Split at ", "
		adbClick(pos1, pos2)
	}
	Delay(1)
}

killGodPackInstance(){
	global winTitle, godPack
	if(godPack = 2) {
		CreateStatusMessage("Pausing script. Found GP.")
		LogToFile("Paused God Pack instance.")
		Pause, On
	} else if(godPack = 1) {
		CreateStatusMessage("Closing script. Found GP.")
		LogToFile("Closing God Pack instance.")
		WinClose, %winTitle%
		ExitApp
	}
}

restartGameInstance(reason, RL := true){
	global Delay, scriptName, adbShell, adbPath, adbPort, friended, loadedAccount
	;initializeAdbShell()
	CreateStatusMessage("Restarting game reason: `n" reason)

	if(!RL || RL != "GodPack") {
		adbShell.StdIn.WriteLine("am force-stop jp.pokemon.pokemontcgp")
		waitadb()
		if(!RL)
			adbShell.StdIn.WriteLine("rm /data/data/jp.pokemon.pokemontcgp/shared_prefs/deviceAccount:.xml") ; delete account data
		waitadb()
		adbShell.StdIn.WriteLine("am start -n jp.pokemon.pokemontcgp/com.unity3d.player.UnityPlayerActivity")
		waitadb()
	}
	Sleep, 4500

	if(RL = "GodPack") {
		LogToFile("Restarted game for instance " scriptName " Reason: " reason, "Restart.txt")
		Reload
	} else if(RL) {
		if(menuDeleteStart()) {
			logMessage := "\n" . username . "\n[" . starCount . "/5][" . packs . "P] " . invalid . " God pack found in instance: " . scriptName . "\nFile name: " . accountFile . "\nGot stuck getting friend code."
			LogToFile(logMessage, "GPlog.txt")
			LogToDiscord(logMessage, screenShot, discordUserId)
		}
		LogToFile("Restarted game for instance " scriptName " Reason: " reason, "Restart.txt")
		Reload
	}
}

menuDelete() {
	sleep, %Delay%
	failSafe := A_TickCount
	failSafeTime := 0
	Loop
	{
		sleep, %Delay%
		sleep, %Delay%
		adbClick(245, 518)
		if(FindImageAndClick(90, 260, 126, 290, , "Settings", , , , 1, failSafeTime)) ;wait for settings menu
			break
		sleep, %Delay%
		sleep, %Delay%
		adbClick(50, 100)
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Settings. It's been: " . failSafeTime "s ")
		LogToFile("In failsafe for Settings. It's been: " . failSafeTime "s ")
	}
	Sleep,%Delay%
	FindImageAndClick(24, 158, 57, 189, , "Account", 140, 440, 2000) ;wait for other menu
	Sleep,%Delay%
	FindImageAndClick(56, 312, 108, 334, , "Account2", 79, 256, 1000) ;wait for account menu
	Sleep,%Delay%

	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			clickButton := FindOrLoseImage(75, 340, 195, 530, 80, "Button", 0, failSafeTime)
			if(!clickButton) {
				clickImage := FindOrLoseImage(140, 340, 250, 530, 60, "DeleteAll", 0, failSafeTime)
				if(clickImage) {
					StringSplit, pos, clickImage, `,  ; Split at ", "
					adbClick(pos1, pos2)
				}
				else {
					adbClick(145, 446)
				}
				Delay(1)
				failSafeTime := (A_TickCount - failSafe) // 1000
				CreateStatusMessage("In failsafe for clicking to delete. " . failSafeTime "/45 seconds")
				LogToFile("In failsafe for clicking to delete. " . failSafeTime "/45 seconds")
			}
			else {
				break
			}
			Sleep,%Delay%
		}
		StringSplit, pos, clickButton, `,  ; Split at ", "
		adbClick(pos1, pos2)
		break
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for clicking to delete. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for clicking to delete. " . failSafeTime "/45 seconds")
	}

	Sleep, 2500
}

menuDeleteStart() {
	global friended
	if(gpFound) {
		return gpFound
	}
	if(friended) {
		FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
		if(setSpeed = 3)
			FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
		else
			FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
		Delay(1)
		adbClick(41, 296)
		Delay(1)
	}
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		if(!friended)
			break
		adbClick(255, 83)
		if(FindOrLoseImage(105, 396, 121, 406, , "Country", 0, failSafeTime)) { ;if at country continue
			break
		}
		else if(FindOrLoseImage(20, 120, 50, 150, , "Menu", 0, failSafeTime)) { ; if the clicks in the top right open up the game settings menu then continue to delete account
			Sleep,%Delay%
			FindImageAndClick(56, 312, 108, 334, , "Account2", 79, 256, 1000) ;wait for account menu
			Sleep,%Delay%
			failSafe := A_TickCount
			failSafeTime := 0
			Loop {
				clickButton := FindOrLoseImage(75, 340, 195, 530, 80, "Button", 0, failSafeTime)
				if(!clickButton) {
					clickImage := FindOrLoseImage(140, 340, 250, 530, 60, "DeleteAll", 0, failSafeTime)
					if(clickImage) {
						StringSplit, pos, clickImage, `,  ; Split at ", "
						adbClick(pos1, pos2)
					}
					else {
						adbClick(145, 446)
					}
					Delay(1)
					failSafeTime := (A_TickCount - failSafe) // 1000
					CreateStatusMessage("In failsafe for clicking to delete. " . failSafeTime "/45 seconds")
					LogToFile("In failsafe for clicking to delete. " . failSafeTime "/45 seconds")
				}
				else {
					break
				}
				Sleep,%Delay%
			}
			StringSplit, pos, clickButton, `,  ; Split at ", "
			adbClick(pos1, pos2)
			break
			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("In failsafe for clicking to delete. " . failSafeTime "/45 seconds")
			LogToFile("In failsafe for clicking to delete. " . failSafeTime "/45 seconds")
		}
		CreateStatusMessage("Looking for Country/Menu")
		Delay(1)
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Country/Menu. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for Country/Menu. " . failSafeTime "/45 seconds")
	}
	if(loadedAccount) {
		FileDelete, %loadedAccount%
	}
}

DoWonderPick() {
	FindImageAndClick(191, 393, 211, 411, , "Shop", 40, 515) ;click until at main menu
	FindImageAndClick(240, 80, 265, 100, , "WonderPick", 59, 429) ;click until in wonderpick Screen
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		adbClick(80, 460)
		if(FindOrLoseImage(240, 80, 265, 100, , "WonderPick", 1, failSafeTime)) {
			clickButton := FindOrLoseImage(100, 367, 190, 480, 100, "Button", 0, failSafeTime)
			if(clickButton) {
				StringSplit, pos, clickButton, `,  ; Split at ", "
					adbClick(pos1, pos2)
				Delay(3)
			}
			if(FindOrLoseImage(160, 330, 200, 370, , "Card", 0, failSafeTime))
				break
		}
		Delay(1)
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for WonderPick. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for WonderPick. " . failSafeTime "/45 seconds")
	}
	Sleep, 300
	if(slowMotion)
		Sleep, 3000
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		adbClick(183, 350) ; click card
		if(FindOrLoseImage(160, 330, 200, 370, , "Card", 1, failSafeTime)) {
			break
		}
		Delay(1)
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Card. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for Card. " . failSafeTime "/45 seconds")
	}
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		adbClick(146, 494)
		if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime) || FindOrLoseImage(240, 80, 265, 100, , "WonderPick", 0, failSafeTime))
			break
		delay(1)
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Shop. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for Shop. " . failSafeTime "/45 seconds")
	}
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		Delay(2)
		if(FindOrLoseImage(191, 393, 211, 411, , "Shop", 0, failSafeTime))
			break
		else if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime))
			adbClick(239, 497)
		else
			adbInputEvent("111") ;send ESC
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Shop. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for Shop. " . failSafeTime "/45 seconds")
	}
	FindImageAndClick(2, 85, 34, 120, , "Missions", 261, 478, 500)
	;FindImageAndClick(130, 170, 170, 205, , "WPMission", 150, 286, 1000)
	FindImageAndClick(120, 185, 150, 215, , "FirstMission", 150, 286, 1000)
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		Delay(1)
		adbClick(139, 424)
		Delay(1)
		clickButton := FindOrLoseImage(145, 447, 258, 480, 80, "Button", 0, failSafeTime)
		if(clickButton) {
			adbClick(110, 369)
		}
		else if(FindOrLoseImage(191, 393, 211, 411, , "Shop", 1, failSafeTime))
			adbInputEvent("111") ;send ESC
		else
			break
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for WonderPick. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for WonderPick. " . failSafeTime "/45 seconds")
	}
	return true
}