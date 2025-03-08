; friends.ahk

RemoveFriends() {
	global friendIDs, stopToggle, friended
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		adbClick(143, 518)
		if(FindOrLoseImage(120, 500, 155, 530, , "Social", 0, failSafeTime))
			break
		else if(FindOrLoseImage(175, 165, 255, 235, , "Hourglass3", 0)) {
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
		}
		Sleep, 500
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Social. " . failSafeTime "/90 seconds")
	}
	FindImageAndClick(226, 100, 270, 135, , "Add", 38, 460, 500)
	FindImageAndClick(205, 430, 255, 475, , "Search", 240, 120, 1500)
	FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
	if(!friendIDs) {
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			adbInput(FriendID)
			Delay(1)
			if(FindOrLoseImage(205, 430, 255, 475, , "Search", 0, failSafeTime)) {
				FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
				EraseInput(1,1)
			} else if(FindOrLoseImage(205, 430, 255, 475, , "Search2", 0, failSafeTime)) {
				break
			}
			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("In failsafe for AddFriends1. " . failSafeTime "/45 seconds")
		}
		failSafe := A_TickCount
		failSafeTime := 0
		Loop {
			adbClick(232, 453)
			if(FindOrLoseImage(165, 250, 190, 275, , "Send", 0, failSafeTime)) {
				break
			} else if(FindOrLoseImage(165, 250, 190, 275, , "Accepted", 0, failSafeTime)) {
				FindImageAndClick(135, 355, 160, 385, , "Remove", 193, 258, 500)
				FindImageAndClick(165, 250, 190, 275, , "Send", 200, 372, 2000)
				break
			} else if(FindOrLoseImage(165, 240, 255, 270, , "Withdraw", 0, failSafeTime)) {
				FindImageAndClick(165, 250, 190, 275, , "Send", 243, 258, 2000)
				break
			}
			Sleep, 750
			failSafeTime := (A_TickCount - failSafe) // 1000
			CreateStatusMessage("In failsafe for AddFriends2. " . failSafeTime "/45 seconds")
		}
		n := 1 ;how many friends added needed to return number for remove friends
	} else {
		;randomize friend id list to not back up mains if running in groups since they'll be sent in a random order.
		n := friendIDs.MaxIndex()
		Loop % n
		{
			i := n - A_Index + 1
			Random, j, 1, %i%
			; Force string assignment with quotes
			temp := friendIDs[i] . ""  ; Concatenation ensures string type
			friendIDs[i] := friendIDs[j] . ""
			friendIDs[j] := temp . ""
		}
		for index, value in friendIDs {
			if (StrLen(value) != 16) {
				; Wrong id value
				continue
			}
			failSafe := A_TickCount
			failSafeTime := 0
			Loop {
				adbInput(value)
				Delay(1)
				if(FindOrLoseImage(205, 430, 255, 475, , "Search", 0, failSafeTime)) {
					FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
					EraseInput()
				} else if(FindOrLoseImage(205, 430, 255, 475, , "Search2", 0, failSafeTime)) {
					break
				}
				failSafeTime := (A_TickCount - failSafe) // 1000
				CreateStatusMessage("In failsafe for AddFriends3. " . failSafeTime "/45 seconds")
			}
			failSafe := A_TickCount
			failSafeTime := 0
			Loop {
				adbClick(232, 453)
				if(FindOrLoseImage(165, 250, 190, 275, , "Send", 0, failSafeTime)) {
					break
				} else if(FindOrLoseImage(165, 250, 190, 275, , "Accepted", 0, failSafeTime)) {
					FindImageAndClick(135, 355, 160, 385, , "Remove", 193, 258, 500)
					FindImageAndClick(165, 250, 190, 275, , "Send", 200, 372, 500)
					break
				} else if(FindOrLoseImage(165, 240, 255, 270, , "Withdraw", 0, failSafeTime)) {
					FindImageAndClick(165, 250, 190, 275, , "Send", 243, 258, 2000)
					break
				}
				Sleep, 750
				failSafeTime := (A_TickCount - failSafe) // 1000
				CreateStatusMessage("In failsafe for AddFriends4. " . failSafeTime "/45 seconds")
			}
			if(index != friendIDs.maxIndex()) {
				FindImageAndClick(205, 430, 255, 475, , "Search2", 150, 50, 1500)
				FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
				EraseInput(index, n)
			}
		}
	}
	if(stopToggle)
		ExitApp
	friended := false
}

AddFriends(renew := false, getFC := false) {
	global FriendID, friendIds, waitTime, friendCode
	friendIDs := ReadFile("ids")
	count := 0
	friended := true
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		if(count > waitTime) {
			break
		}
		if(count = 0) {
			failSafe := A_TickCount
			failSafeTime := 0
			Loop {
				adbClick(143, 518)
				Delay(1)
				if(FindOrLoseImage(120, 500, 155, 530, , "Social", 0, failSafeTime)) {
					break
				}
				else if(!renew && !getFC) {
					clickButton := FindOrLoseImage(75, 340, 195, 530, 80, "Button", 0)
					if(clickButton) {
						StringSplit, pos, clickButton, `,  ; Split at ", "
						adbClick(pos1, pos2)
					}
				}
				else if(FindOrLoseImage(175, 165, 255, 235, , "Hourglass3", 0)) {
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
				}
				failSafeTime := (A_TickCount - failSafe) // 1000
				CreateStatusMessage("In failsafe for Social. " . failSafeTime "/90 seconds")
			}
			FindImageAndClick(226, 100, 270, 135, , "Add", 38, 460, 500)
			FindImageAndClick(205, 430, 255, 475, , "Search", 240, 120, 1500)
			if(getFC) {
				Delay(3)
				adbClick(210, 342)
				Delay(3)
				friendCode := Clipboard
				return friendCode
			}
			FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
			if(!friendIDs) {
				failSafe := A_TickCount
				failSafeTime := 0
				Loop {
					adbInput(FriendID)
					Delay(1)
					if(FindOrLoseImage(205, 430, 255, 475, , "Search", 0, failSafeTime)) {
						FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
						EraseInput(1,1)
					} else if(FindOrLoseImage(205, 430, 255, 475, , "Search2", 0, failSafeTime)) {
						break
					}
					failSafeTime := (A_TickCount - failSafe) // 1000
					CreateStatusMessage("In failsafe for AddFriends1. " . failSafeTime "/45 seconds")
				}
				failSafe := A_TickCount
				failSafeTime := 0
				Loop {
					adbClick(232, 453)
					if(FindOrLoseImage(165, 250, 190, 275, , "Send", 0, failSafeTime)) {
						adbClick(243, 258)
						Delay(2)
						break
					}
					else if(FindOrLoseImage(165, 240, 255, 270, , "Withdraw", 0, failSafeTime)) {
						break
					}
					else if(FindOrLoseImage(165, 250, 190, 275, , "Accepted", 0, failSafeTime)) {
						if(renew){
							FindImageAndClick(135, 355, 160, 385, , "Remove", 193, 258, 500)
							FindImageAndClick(165, 250, 190, 275, , "Send", 200, 372, 500)
							if(!friended)
								ExitApp
							Delay(2)
							adbClick(243, 258)
						}
						break
					}
					Sleep, 750
					failSafeTime := (A_TickCount - failSafe) // 1000
					CreateStatusMessage("In failsafe for AddFriends2. " . failSafeTime "/45 seconds")
				}
				n := 1 ;how many friends added needed to return number for remove friends
			}
			else {
				;randomize friend id list to not back up mains if running in groups since they'll be sent in a random order.
				n := friendIDs.MaxIndex()
				Loop % n
				{
					i := n - A_Index + 1
					Random, j, 1, %i%
					; Force string assignment with quotes
					temp := friendIDs[i] . ""  ; Concatenation ensures string type
					friendIDs[i] := friendIDs[j] . ""
					friendIDs[j] := temp . ""
				}
				for index, value in friendIDs {
					if (StrLen(value) != 16) {
						; Wrong id value
						continue
					}
					failSafe := A_TickCount
					failSafeTime := 0
					Loop {
						adbInput(value)
						Delay(1)
						if(FindOrLoseImage(205, 430, 255, 475, , "Search", 0, failSafeTime)) {
							FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
							EraseInput()
						} else if(FindOrLoseImage(205, 430, 255, 475, , "Search2", 0, failSafeTime)) {
							break
						}
						failSafeTime := (A_TickCount - failSafe) // 1000
						CreateStatusMessage("In failsafe for AddFriends3. " . failSafeTime "/45 seconds")
					}
					failSafe := A_TickCount
					failSafeTime := 0
					Loop {
						adbClick(232, 453)
						if(FindOrLoseImage(165, 250, 190, 275, , "Send", 0, failSafeTime)) {
							adbClick(243, 258)
							Delay(2)
							break
						}
						else if(FindOrLoseImage(165, 240, 255, 270, , "Withdraw", 0, failSafeTime)) {
							break
						}
						else if(FindOrLoseImage(165, 250, 190, 275, , "Accepted", 0, failSafeTime)) {
							if(renew){
								FindImageAndClick(135, 355, 160, 385, , "Remove", 193, 258, 500)
								FindImageAndClick(165, 250, 190, 275, , "Send", 200, 372, 500)
								Delay(2)
								adbClick(243, 258)
							}
							break
						}
						Sleep, 750
						failSafeTime := (A_TickCount - failSafe) // 1000
						CreateStatusMessage("In failsafe for AddFriends4. " . failSafeTime "/45 seconds")
					}
					if(index != friendIDs.maxIndex()) {
						FindImageAndClick(205, 430, 255, 475, , "Search2", 150, 50, 1500)
						FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
						EraseInput(index, n)
					}
				}
			}
			FindImageAndClick(120, 500, 155, 530, , "Social", 143, 518, 500)
			FindImageAndClick(20, 500, 55, 530, , "Home", 40, 516, 500)
		}
		CreateStatusMessage("Waiting for friends to accept request. `n" . count . "/" . waitTime . " seconds.")
		sleep, 1000
		count++
	}
	return n ;return added friends so we can dynamically update the .txt in the middle of a run without leaving friends at the end
}

EraseInput(num := 0, total := 0) {
	if(num)
		CreateStatusMessage("Removing friend ID " . num . "/" . total)
	failSafe := A_TickCount
	failSafeTime := 0
	Loop {
		FindImageAndClick(0, 475, 25, 495, , "OK2", 138, 454)
		Loop 20 {
			adbInputEvent("67")
			Sleep, 10
		}
		if(FindOrLoseImage(15, 500, 68, 520, , "Erase", 0, failSafeTime))
			break
	}
	failSafeTime := (A_TickCount - failSafe) // 1000
	CreateStatusMessage("In failsafe for EraseInput. " . failSafeTime "/45 seconds")
	LogToFile("In failsafe for Erase. " . failSafeTime "/45 seconds")
}

getFriendCode() {
	global friendCode
	CreateStatusMessage("Getting friend code")
	Sleep, 2000
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
		else if(FindOrLoseImage(20, 500, 55, 530, , "Home", 0, failSafeTime)) {
			break
		}
		failSafeTime := (A_TickCount - failSafe) // 1000
		CreateStatusMessage("In failsafe for Home. " . failSafeTime "/45 seconds")
		LogToFile("In failsafe for Home. " . failSafeTime "/45 seconds")
		if(failSafeTime > 45)
			restartGameInstance("Stuck at Home")
	}
	friendCode := AddFriends(false, true)

	return friendCode
}