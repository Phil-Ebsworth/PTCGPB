; tutorial.ahk

DoTutorial() {
	FindImageAndClick(105, 396, 121, 406, , "Country", 143, 370) ;select month and year and click

	Delay(1)
	adbClick(80, 400)
	Delay(1)
	adbClick(80, 375)
	Delay(1)
	failSafe := A_TickCount
	failSafeTime := 0

	Loop
	{
		Delay(1)
		if(FindImageAndClick(100, 386, 138, 416, , "Month", , , , 1, failSafeTime))
			break
		Delay(1)
		adbClick(142, 159)
		Delay(1)
		adbClick(80, 400)
		Delay(1)
		adbClick(80, 375)
		Delay(1)
		adbClick(82, 422)
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Month. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for Month. " . failSafeTime "/45 seconds")
	} ;select month and year and click

	adbClick(200, 400)
	Delay(1)
	adbClick(200, 375)
	Delay(1)
	failSafe := A_TickCount
	failSafeTime := 0
	Loop ;select month and year and click
	{
		Delay(1)
		if(FindImageAndClick(148, 384, 256, 419, , "Year", , , , 1, failSafeTime))
			break
		Delay(1)
		adbClick(142, 159)
		Delay(1)
		adbClick(142, 159)
		Delay(1)
		adbClick(200, 400)
		Delay(1)
		adbClick(200, 375)
		Delay(1)
		adbClick(142, 159)
		Delay(1)
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Year. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for Year. " . failSafeTime "/45 seconds")
	} ;select month and year and click

	Delay(1)
	if(FindOrLoseImage(93, 471, 122, 485, , "CountrySelect", 0)) {
		FindImageAndClick(110, 134, 164, 160, , "CountrySelect2", 141, 237, 500)
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			countryOK := FindOrLoseImage(93, 450, 122, 470, , "CountrySelect", 0, failSafeTime)
			birthFound := FindOrLoseImage(116, 352, 138, 389, , "Birth", 0, failSafeTime)
			if(countryOK)
				adbClick(124, 250)
			else if(!birthFound)
					adbClick(140, 474)
			else if(birthFound)
				break
			Delay(2)
			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("In failsafe for country select. " . failSafeTime "/45 seconds")
			LogToFile("In failsafe for country select. " . failSafeTime "/45 seconds")
		}
	} else {
		FindImageAndClick(116, 352, 138, 389, , "Birth", 140, 474, 1000)
	}

	;wait date confirmation screen while clicking ok

	FindImageAndClick(210, 285, 250, 315, , "TosScreen", 203, 371, 1000) ;wait to be at the tos screen while confirming birth

	FindImageAndClick(129, 477, 156, 494, , "Tos", 139, 299, 1000) ;wait for tos while clicking it

	FindImageAndClick(210, 285, 250, 315, , "TosScreen", 142, 486, 1000) ;wait to be at the tos screen and click x

	FindImageAndClick(129, 477, 156, 494, , "Privacy", 142, 339, 1000) ;wait to be at the tos screen

	FindImageAndClick(210, 285, 250, 315, , "TosScreen", 142, 486, 1000) ;wait to be at the tos screen, click X

	Delay(1)
	adbClick(261, 374)

	Delay(1)
	adbClick(261, 406)

	Delay(1)
	adbClick(145, 484)

	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		if(FindImageAndClick(30, 336, 53, 370, , "Save", 145, 484, , 2, failSafeTime)) ;wait to be at create save data screen while clicking
			break
		Delay(1)
		adbClick(261, 406)
		if(FindImageAndClick(30, 336, 53, 370, , "Save", 145, 484, , 2, failSafeTime)) ;wait to be at create save data screen while clicking
			break
		Delay(1)
		adbClick(261, 374)
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Save. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for Save. " . failSafeTime "/45 seconds")
	}

	Delay(1)

	adbClick(143, 348)

	Delay(1)

	FindImageAndClick(51, 335, 107, 359, , "Link") ;wait for link account screen%
	Delay(1)
	failSafe := A_TickCount
	failSafeTime := 0
		Loop {
			if(FindOrLoseImage(51, 335, 107, 359, , "Link", 0, failSafeTime)) {
				adbClick(140, 460)
				Loop {
					Delay(1)
					if(FindOrLoseImage(51, 335, 107, 359, , "Link", 1, failSafeTime)) {
						adbClick(140, 380) ; click ok on the interrupted while opening pack prompt
						break
					}
					failSafeTime := (A_TickCount - failSafe) // 1000
				}
			} else if(FindOrLoseImage(110, 350, 150, 404, , "Confirm", 0, failSafeTime)) {
				adbClick(203, 364)
			} else if(FindOrLoseImage(215, 371, 264, 418, , "Complete", 0, failSafeTime)) {
				adbClick(140, 370)
			} else if(FindOrLoseImage(0, 46, 20, 70, , "Cinematic", 0, failSafeTime)) {
				break
			}
			;CreateStatusMessage("Looking for Link/Welcome")
			Delay(1)
			failSafeTime := (A_TickCount - failSafe) // 1000
			;CreateStatusMessage("In failsafe for Link/Welcome. " . failSafeTime "/45 seconds")
		}

		if(setSpeed = 3) {
			FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
			FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
			Delay(1)
			adbClick(41, 296)
			Delay(1)
		}

		FindImageAndClick(110, 230, 182, 257, , "Welcome", 253, 506, 110) ;click through cutscene until welcome page

		if(setSpeed = 3) {
			FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings

			FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click mod settings
			Delay(1)
			adbClick(41, 296)
		}
	FindImageAndClick(190, 241, 225, 270, , "Name", 189, 438) ;wait for name input screen

	FindImageAndClick(0, 476, 40, 502, , "OK", 139, 257) ;wait for name input screen

	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		name := ReadFile("usernames")
		Random, randomIndex, 1, name.MaxIndex()
		username := name[randomIndex]
		username := SubStr(username, 1, 14)  ;max character limit
		adbInput(username)
		if(FindImageAndClick(121, 490, 161, 520, , "Return", 185, 372, , 10)) ;click through until return button on open pack
			break
		adbClick(90, 370)
		Delay(1)
		adbClick(139, 254) ; 139 254 194 372
		Delay(1)
		adbClick(139, 254)
		Delay(1)
		EraseInput() ; incase the random pokemon is not accepted
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Trace. " . failSafeTime "/45 seconds")
		CreateStatusMessage("In failsafe for Trace. " . failSafeTime "/45 seconds")
		if(failSafeTime > 45)
			restartGameInstance("Stuck at name")
	}

	Delay(1)

	adbClick(140, 424)

	FindImageAndClick(203, 273, 228, 290, , "Pack", 140, 424) ;wait for pack to be ready  to trace
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
						FindImageAndClick(182, 170, 194, 190, , "Three", 187, 180) ; click 3x
				else
						FindImageAndClick(100, 170, 113, 190, , "Two", 107, 180) ; click 2x
			}
			adbClick(41, 296)
				break
		}
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Pack. " . failSafeTime "/45 seconds")
	}

	FindImageAndClick(34, 99, 74, 131, , "Swipe", 140, 375) ;click through cards until needing to swipe up
		if(setSpeed > 1) {
			FindImageAndClick(65, 195, 100, 215, , "Platin", 18, 109, 2000) ; click mod settings
			FindImageAndClick(9, 170, 25, 190, , "One", 26, 180) ; click mod settings
			Delay(1)
		}
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		adbSwipeUp()
		Sleep, 10
		if (FindOrLoseImage(120, 70, 150, 95, , "SwipeUp", 0, failSafeTime)){
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
		CreateStatusMessage("In failsafe for swipe up. " . failSafeTime "/45 seconds")
		Delay(1)
	}

	Delay(1)
	if(setSpeed > 2) {
		FindImageAndClick(136, 420, 151, 436, , "Move", 134, 375, 500) ; click through until move
		FindImageAndClick(50, 394, 86, 412, , "Proceed", 141, 483, 750) ;wait for menu to proceed then click ok. increased delay in between clicks to fix freezing on 3x speed
	}
	else {
		FindImageAndClick(136, 420, 151, 436, , "Move", 134, 375) ; click through until move
		FindImageAndClick(50, 394, 86, 412, , "Proceed", 141, 483) ;wait for menu to proceed then click ok
	}

	Delay(1)
	adbClick(204, 371)

	FindImageAndClick(46, 368, 103, 411, , "Gray") ;wait for for missions to be clickable

	Delay(1)
	adbClick(247, 472)

	FindImageAndClick(115, 97, 174, 150, , "Pokeball", 247, 472, 5000) ; click through missions until missions is open

	Delay(1)
	adbClick(141, 294)
	Delay(1)
	adbClick(141, 294)
	Delay(1)
	FindImageAndClick(124, 168, 162, 207, , "Register", 141, 294, 1000) ; wait for register screen
	Delay(6)
	adbClick(140, 500)

	FindImageAndClick(115, 255, 176, 308, , "Mission") ; wait for mission complete screen

	FindImageAndClick(46, 368, 103, 411, , "Gray", 143, 360) ;wait for for missions to be clickable

	FindImageAndClick(170, 160, 220, 200, , "Notifications", 145, 194) ;click on packs. stop at booster pack tutorial

	Delay(3)
	adbClick(142, 436)
	Delay(3)
	adbClick(142, 436)
	Delay(3)
	adbClick(142, 436)
	Delay(3)
	adbClick(142, 436)

	FindImageAndClick(203, 273, 228, 290, , "Pack", 239, 497) ;wait for pack to be ready  to Trace
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
		CreateStatusMessage("In failsafe for Pack. " . failSafeTime "/45 seconds")
		Delay(1)
	}

	FindImageAndClick(0, 98, 116, 125, 5, "Opening", 239, 497) ;skip through cards until results opening screen

	FindImageAndClick(233, 486, 272, 519, , "Skip", 146, 496) ;click on next until skip button appears

	FindImageAndClick(120, 70, 150, 100, , "Next", 239, 497, , 2)

	FindImageAndClick(53, 281, 86, 310, , "Wonder", 146, 494) ;click on next until skip button appearsstop at hourglasses tutorial

	Delay(3)

	adbClick(140, 358)

	FindImageAndClick(191, 393, 211, 411, , "Shop", 146, 444) ;click until at main menu

	FindImageAndClick(87, 232, 131, 266, , "Wonder2", 79, 411) ; click until wonder pick tutorial screen

	FindImageAndClick(114, 430, 155, 441, , "Wonder3", 190, 437) ; click through tutorial

	Delay(2)

	FindImageAndClick(155, 281, 192, 315, , "Wonder4", 202, 347, 500) ; confirm wonder pick selection

	Delay(2)

	adbClick(208, 461)

	if(setSpeed = 3) ;time the animation
		Sleep, 1500
	else
		Sleep, 2500

	FindImageAndClick(60, 130, 202, 142, 10, "Pick", 208, 461, 350) ;stop at pick a card

	Delay(1)

	adbClick(187, 345)

	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		if(setSpeed = 3)
			continueTime := 1
		else
			continueTime := 3

		if(FindOrLoseImage(233, 486, 272, 519, , "Skip", 0, failSafeTime)) {
			adbClick(239, 497)
		} else if(FindOrLoseImage(110, 230, 182, 257, , "Welcome", 0, failSafeTime)) { ;click through to end of tut screen
			break
		} else if(FindOrLoseImage(120, 70, 150, 100, , "Next", 0, failSafeTime)) {
			adbClick(146, 494) ;146, 494
		} else if(FindOrLoseImage(120, 70, 150, 100, , "Next2", 0, failSafeTime)) {
			adbClick(146, 494) ;146, 494
		}
		else {
			adbClick(187, 345)
			Delay(1)
			adbClick(143, 492)
			Delay(1)
			adbClick(143, 492)
			Delay(1)
		}
		Delay(1)

		; adbClick(66, 446)
		; Delay(1)
		; adbClick(66, 446)
		; Delay(1)
		; adbClick(66, 446)
		; Delay(1)
		; adbClick(187, 345)
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for End. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for End. " . failSafeTime "/45 seconds")
	}

	FindImageAndClick(120, 316, 143, 335, , "Main", 192, 449) ;click until at main menu

	return true
}