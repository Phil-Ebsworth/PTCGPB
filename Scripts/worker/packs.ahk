; packs.ahk

PackOpening() {
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		adbClick(146, 439)
		Delay(1)
		if(FindOrLoseImage(225, 273, 235, 290, , "Pack", 0, failSafeTime))
			break ;wait for pack to be ready to Trace and click skip
		else
			adbClick(239, 497)
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Pack. " . failSafeTime "/45 seconds")
		if(failSafeTime > 45)
			restartGameInstance("Stuck at Pack")
	}

	if(setSpeed > 1) {
	FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
	FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
		Delay(1)
	}
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		adbSwipe()
		Sleep, 10
		if (FindOrLoseImage(203, 273, 228, 290, , "Pack", 1, failSafeTime)){
		if(setSpeed > 1) {
			if(setSpeed = 3)
					FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
			else
					FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
		}
			adbClick(41, 296)
			break
		}
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Trace. " . failSafeTime "/45 seconds")
		Delay(1)
	}

	FindImageAndClick(0, 98, 116, 125, 5, "Opening", 239, 497) ;skip through cards until results opening screen

	CheckPack()

	FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 494) ;click on next until skip button appears

	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		Delay(1)
		if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
			adbClick(239, 497)
		} else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
			adbClick(146, 494) ;146, 494
		} else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
			adbClick(146, 494) ;146, 494
		} else if(FindOrLoseImage(121, 465, 140, 485, , "ConfirmPack", 0, failSafeTime)) {
			break
		} else if(FindOrLoseImage(178, 193, 251, 282, , "Hourglass", 0, failSafeTime)) {
			break
		}
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Home. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for Home. " . failSafeTime "/45 seconds")
		if(failSafeTime > 45)
			restartGameInstance("Stuck at Home")
	}
}

CheckPack() {
	foundGP := false ;check card border to find godpacks
	foundTrainer := false
	foundRainbow := false
	foundFullArt := false
	foundCrown := false
	foundImmersive := false
	foundTS := false
	foundGP := FindGodPack()
	;msgbox 1 foundGP:%foundGP%, TC:%TrainerCheck%, RC:%RainbowCheck%, FAC:%FullArtCheck%, FTS:%foundTS%
	if(TrainerCheck && !foundTS) {
		foundTrainer := FindBorders("trainer")
		if(foundTrainer)
			foundTS := "Trainer"
	}
	if(RainbowCheck && !foundTS) {
		foundRainbow := FindBorders("rainbow")
		if(foundRainbow)
			foundTS := "Rainbow"
	}
	if(FullArtCheck && !foundTS) {
		foundFullArt := FindBorders("fullart")
		if(foundFullArt)
			foundTS := "Full Art"
	}
	if(ImmersiveCheck && !foundTS) {
		foundImmersive := FindBorders("immersive")
		if(foundImmersive)
			foundTS := "Immersive"
	}
	If(CrownCheck && !foundTS) {
		foundCrown := FindBorders("crown")
		if(foundCrown)
			foundTS := "Crown"
	}
	If(PseudoGodPack && !foundTS) {
		2starCount := FindBorders("trainer") + FindBorders("rainbow") + FindBorders("fullart")
		if(2starCount > 1)
			foundTS := "Double two star"
	}
	if(foundGP || foundTrainer || foundRainbow || foundFullArt || foundImmersive || foundCrown || 2starCount > 1) {
		if(loadedAccount)
			FileDelete, %loadedAccount% ;delete xml file from folder if using inject method
		if(foundGP)
			restartGameInstance("God Pack found. Continuing...", "GodPack") ; restarts to backup and delete xml file with account info.
		else {
			FoundStars(foundTS)
			restartGameInstance(foundTS . " found. Continuing...", "GodPack") ; restarts to backup and delete xml file with account info.
		}
	}
}

FoundStars(star) {
	screenShot := Screenshot(star)
	accountFile := saveAccount(star)
	friendCode := getFriendCode()

	; Pull back screenshot of the friend code/name (good for inject method)
	Sleep, 8000
	fcScreenshot := Screenshot("FRIENDCODE")

	if(star = "Crown" || star = "Immersive")
		RemoveFriends()
	logMessage := star . " found by " . username . " (" . friendCode . ") in instance: " . scriptName . " (" . packs . " packs)\nFile name: " . accountFile . "\nBacking up to the Accounts\\SpecificCards folder and continuing..."
	CreateStatusMessage(logMessage)
	LogToFile(logMessage, "GPlog.txt")
	LogToDiscord(logMessage, screenShot, discordUserId, "", fcScreenshot)
}

FindBorders(prefix) {
	count := 0
	searchVariation := 40
	borderCoords := [[30, 284, 83, 286]
		,[113, 284, 166, 286]
		,[196, 284, 249, 286]
		,[70, 399, 123, 401]
		,[155, 399, 208, 401]]
	pBitmap := from_window(WinExist(winTitle))
	; imagePath := "C:\Users\Arturo\Desktop\PTCGP\GPs\" . Clipboard . ".png"
	; pBitmap := Gdip_CreateBitmapFromFile(imagePath)
	for index, value in borderCoords {
		coords := borderCoords[A_Index]
		Path = %A_ScriptDir%\%defaultLanguage%\%prefix%%A_Index%.png
		pNeedle := GetNeedle(Path)
		vRet := Gdip_ImageSearch(pBitmap, pNeedle, vPosXY, coords[1], coords[2], coords[3], coords[4], searchVariation)
		if (vRet = 1) {
			count += 1
		}
	}
	Gdip_DisposeImage(pBitmap)
	return count
}

FindGodPack() {
	global winTitle, discordUserId, Delay, username, packs, minStars
	gpFound := false
	invalidGP := false
	searchVariation := 5
	confirm := false
	Loop {
		if(FindBorders("lag") = 0)
			break
		Delay(1)
	}
	borderCoords := [[20, 284, 90, 286]
		,[103, 284, 173, 286]]
	if(packs = 3)
		packs := 0
	Loop {
		normalBorders := false
		pBitmap := from_window(WinExist(winTitle))
		Path = %A_ScriptDir%\%defaultLanguage%\Border.png
		pNeedle := GetNeedle(Path)
		for index, value in borderCoords {
			coords := borderCoords[A_Index]
			vRet := Gdip_ImageSearch(pBitmap, pNeedle, vPosXY, coords[1], coords[2], coords[3], coords[4], searchVariation)
			if (vRet = 1) {
				normalBorders := true
				break
			}
		}
		Gdip_DisposeImage(pBitmap)
		if(normalBorders) {
			CreateStatusMessage("Not a God Pack ")
			packs += 1
			break
		} else {
			packs += 1
			if(packMethod)
				packs := 1
			foundImmersive := FindBorders("immersive")
			foundCrown := FindBorders("crown")
			if(foundImmersive || foundCrown) {
				invalidGP := true
			}
			if(!invalidGP && minStars > 0) {
				starCount := 5 - FindBorders("1star")
				if(starCount < minStars) {
					CreateStatusMessage("Does not meet minimum 2 star threshold.")
					invalidGP := true
				}
			}
			if(invalidGP) {
				gpFound := true
				GodPackFound("Invalid")
				RemoveFriends()
				break
			}
			else {
				gpFound := true
				GodPackFound("Valid")
				break
			}
		}
	}
	return gpFound
}

GodPackFound(validity) {
	if(validity = "Valid") {
		Praise := ["Congrats!", "Congratulations!", "GG!", "Whoa!", "Praise Helix! ༼ つ ◕_◕ ༽つ", "Way to go!", "You did it!", "Awesome!", "Nice!", "Cool!", "You deserve it!", "Keep going!", "This one has to be live!", "No duds, no duds, no duds!", "Fantastic!", "Bravo!", "Excellent work!", "Impressive!", "You're amazing!", "Well done!", "You're crushing it!", "Keep up the great work!", "You're unstoppable!", "Exceptional!", "You nailed it!", "Hats off to you!", "Sweet!", "Kudos!", "Phenomenal!", "Boom! Nailed it!", "Marvelous!", "Outstanding!", "Legendary!", "Youre a rock star!", "Unbelievable!", "Keep shining!", "Way to crush it!", "You're on fire!", "Killing it!", "Top-notch!", "Superb!", "Epic!", "Cheers to you!", "Thats the spirit!", "Magnificent!", "Youre a natural!", "Gold star for you!", "You crushed it!", "Incredible!", "Shazam!", "You're a genius!", "Top-tier effort!", "This is your moment!", "Powerful stuff!", "Wicked awesome!", "Props to you!", "Big win!", "Yesss!", "Champion vibes!", "Spectacular!"]
		invalid := ""
	} else {
		Praise := ["Uh-oh!", "Oops!", "Not quite!", "Better luck next time!", "Yikes!", "That didn’t go as planned.", "Try again!", "Almost had it!", "Not your best effort.", "Keep practicing!", "Oh no!", "Close, but no cigar.", "You missed it!", "Needs work!", "Back to the drawing board!", "Whoops!", "That’s rough!", "Don’t give up!", "Ouch!", "Swing and a miss!", "Room for improvement!", "Could be better.", "Not this time.", "Try harder!", "Missed the mark.", "Keep at it!", "Bummer!", "That’s unfortunate.", "So close!", "Gotta do better!"]
		invalid := validity
	}
	Randmax := Praise.Length()
	Random, rand, 1, Randmax
	Interjection := Praise[rand]
	starCount := 5 - FindBorders("1star")
	screenShot := Screenshot(validity)
	accountFile := saveAccount(validity)
	logMessage := "\n" . username . "\n[" . starCount . "/5][" . packs . "P] " . invalid . " God pack found in instance: " . scriptName . "\nFile name: " . accountFile . "\nGetting friend code then sendind discord message."
	godPackLog = GPlog.txt
	LogToFile(logMessage, godPackLog)
	CreateStatusMessage(logMessage)
	friendCode := getFriendCode()

	; Pull screenshot of the Friend code page; wait so we don't get the clipboard pop up; good for the inject method
	Sleep, 8000
	fcScreenshot := Screenshot("FRIENDCODE")

	logMessage := Interjection . "\n" . username . " (" . friendCode . ")\n[" . starCount . "/5][" . packs . "P] " . invalid . " God pack found in instance: " . scriptName . "\nFile name: " . accountFile . "\nBacking up to the Accounts\\GodPacks folder and continuing..."
	LogToFile(logMessage, godPackLog)
	;Run, http://google.com, , Hide ;Remove the ; at the start of the line and replace your url if you want to trigger a link when finding a god pack.
	LogToDiscord(logMessage, screenShot, discordUserId, "", fcScreenshot)
}

SelectPack(HG := false) {
	global openPack, packArray
	packy := 196
	if(openPack = "Mew") {
		packx := 80
	} else if(openPack = "Arceus") {
		packx := 145
	} else {
		packx := 200
	}
	FindImageAndClick(233, 400, 264, 428, , "Points", packx, packy)
	if(openPack = "Pikachu" || openPack = "Mewtwo" || openPack = "Charizard") {
		packy := 442
		if(openPack = "Pikachu"){
            packx := 245
        } else if(openPack = "Mewtwo"){
            packx := 205
        } else if(openPack = "Charizard"){
            packx := 165
        }
		FindImageAndClick(115, 140, 160, 155, , "SelectExpansion", 245, 475)
		FindImageAndClick(233, 400, 264, 428, , "Points", packx, packy)
	} else if(openPack = "Palkia") {
		Delay(2)
		adbClick(245, 245) ;temp
		Delay(2)
	}
	if(HG = "Tutorial") {
		FindImageAndClick(236, 198, 266, 226, , "Hourglass2", 180, 436, 500) ;stop at hourglasses tutorial 2 180 to 203?
	}
	else if(HG = "HGPack") {
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 0, failSafeTime)) {
				break
			}
			adbClick(146, 439)
			Delay(1)
			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("In failsafe for HourglassPack3. " . failSafeTime "/45 seconds")
		}
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 1, failSafeTime)) {
				break
			}
			adbClick(205, 458)
			Delay(1)
			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("In failsafe for HourglassPack4. " . failSafeTime "/45 seconds")
		}
	}
	;if(HG != "Tutorial")
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			if(FindImageAndClick(233, 486, 272, 519, , "Skip2", 130, 430, , 2)) ;click on next until skip button appears
				break
			Delay(1)
			adbClick(200, 461)
			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("In failsafe for Skip2. " . failSafeTime "/45 seconds")
		}
}


HourglassOpening(HG := false) {
	if(!HG) {
		Delay(3)
		adbClick(146, 441) ; 146 440
		Delay(3)
		adbClick(146, 441)
		Delay(3)
		adbClick(146, 441)
		Delay(3)

		FindImageAndClick(98, 184, 151, 224, , "Hourglass1", 168, 438, 500, 5) ;stop at hourglasses tutorial 2
		Delay(1)

		adbClick(203, 436) ; 203 436

		if(packMethod) {
			AddFriends(true)
			SelectPack("Tutorial")
		}
		else {
			FindImageAndClick(236, 198, 266, 226, , "Hourglass2", 180, 436, 500) ;stop at hourglasses tutorial 2 180 to 203?
		}
	}
	if(!packMethod) {
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 0, failSafeTime)) {
				break
			}
			adbClick(146, 439)
			Delay(1)
			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("In failsafe for HourglassPack. " . failSafeTime "/45 seconds")
		}
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			if(FindOrLoseImage(60, 440, 90, 480, , "HourglassPack", 1, failSafeTime)) {
				break
			}
			adbClick(205, 458)
			Delay(1)
			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("In failsafe for HourglassPack2. " . failSafeTime "/45 seconds")
		}
	}
	Loop {
		adbClick(146, 439)
		Delay(1)
		if(FindOrLoseImage(225, 273, 235, 290, , "Pack", 0, failSafeTime))
			break ;wait for pack to be ready to Trace and click skip
		else
			adbClick(239, 497)
		clickButton := FindOrLoseImage(145, 440, 258, 480, 80, "Button", 0, failSafeTime)
		if(clickButton) {
			StringSplit, pos, clickButton, `,  ; Split at ", "
			adbClick(pos1, pos2)
		}
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Pack. " . failSafeTime "/45 seconds")
		if(failSafeTime > 45)
			restartGameInstance("Stuck at Pack")
	}

	if(setSpeed > 1) {
	FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
	FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
		Delay(1)
	}
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		adbSwipe()
		Sleep, 10
		if (FindOrLoseImage(203, 273, 228, 290, , "Pack", 1, failSafeTime)){
		if(setSpeed > 1) {
			if(setSpeed = 3)
					FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
			else
					FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click mod settings
		}
			adbClick(41, 296)
			break
		}
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Trace. " . failSafeTime "/45 seconds")
		Delay(1)
	}

	FindImageAndClick(0, 98, 116, 125, 5, "Opening", 239, 497) ;skip through cards until results opening screen

	CheckPack()

	FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 494) ;click on next until skip button appears

	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		Delay(1)
		if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
			adbClick(239, 497)
		} else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
			adbClick(146, 494) ;146, 494
		} else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
			adbClick(146, 494) ;146, 494
		} else if(FindOrLoseImage(121, 465, 140, 485, , "ConfirmPack", 0, failSafeTime)) {
			break
		}
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for ConfirmPack. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for ConfirmPack. " . failSafeTime "/45 seconds")
		if(failSafeTime > 45)
			restartGameInstance("Stuck at ConfirmPack")
	}
}