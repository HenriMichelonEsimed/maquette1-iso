extends InteractiveCharacter

func _init():
	var d1 = []
	d1.append_array([
		["Congratulation, you won the game !!", a1], [
			["Wow, thank you !", [
				"You can now roam freely in the station", [
					["Let's talk.", d1],
					["Nice. Bye.", end]
				]
			]],
			["Ok, bye", end]
		]
	])
	super(
		["Hello.", [
			["Hello, nice to meet you.", d1]
		]]
	)

func a1():
	QuestsEvents.event(QuestEvents.QuestEventType.QUESTEVENT_TALK, "QAMain1_end")
	end()
