extends InteractiveCharacter

func _init():
	super(
		["Hello.", [
			["Hey, what's on the menu?.", _trade],
			["Bye.", _end]
		]]
	)
