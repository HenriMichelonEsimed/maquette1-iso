extends InteractiveCharacter

func _init():
	var d1 = []
	d1.append_array([
		["Congratulation, you won the game !!", a1], [
			["Wow, thank you !", [
				"You can now roam freely in the station", [
					["Let's talk", d1],
					["Nice. Bye", _end]
				]
			]],
			["Ok, bye", _end]
		]
	])
	super(
		["Hello", [
			["Hello, nice to meet you", d1]
		]]
	)

func a1():
	GameState.quests.event("main", Quest.QuestEventType.QUESTEVENT_TALK, "QMain1_end")
	_end()
