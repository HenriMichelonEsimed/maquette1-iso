extends InteractiveCharacter

func interact():
	say(0, "Hello.", ["Hello, nice to meet you."])
	
func answer(index:int):
	if level == 0:
		if index == 0:
			say(1, "Congratulation, you won the game !!", ["Wow, thank you !", "Ok, bye"])
			QuestsEvents.event(QuestEvents.QuestEventType.QUESTEVENT_TALK, "QAMain1_end")
	elif level == 1:
		if index == 0:
			say(2, "You can now roam freely in the station", ["Nice. Bye."])
		elif index == 1:
			end()
	elif level == 2:
		end()
