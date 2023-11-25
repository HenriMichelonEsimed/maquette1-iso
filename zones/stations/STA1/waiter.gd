extends InteractiveCharacter

func _init():
	super(
		["Hello.", [
			["Hey, what's on the menu?.", _trade],
			["Bye.", _end]
		]],
		[
			[ Item.ItemType.ITEM_CONSUMABLES, "orange_1", 16],
			[ Item.ItemType.ITEM_CONSUMABLES, "ham_sandwich_1", 4],
			[ Item.ItemType.ITEM_CONSUMABLES, "pizza_1", 4],
			[ Item.ItemType.ITEM_CONSUMABLES, "soft_drink_1", 10],
		], 10
	)
	if not GameState.quests.have_advpoint("main", "lvl0_generate_ham_sandwich"):
		if not items.have(Item.ItemType.ITEM_CONSUMABLES, "ham_sandwich_1"):
			items.new(Item.ItemType.ITEM_CONSUMABLES, "ham_sandwich_1")
