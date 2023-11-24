extends InteractiveCharacter

func _init():
	super(
		["Hello.", [
			["Hey, what's on the menu?.", _trade],
			["Bye.", _end]
		]],
		[
			[ Item.ItemType.ITEM_QUEST, "access_card_1"],
			[ Item.ItemType.ITEM_MISCELLANEOUS, "credit", 10],
			[ Item.ItemType.ITEM_CONSUMABLES, "orange_1", 16],
			[ Item.ItemType.ITEM_CONSUMABLES, "ham_sandwich_1", 5],
			[ Item.ItemType.ITEM_CONSUMABLES, "pizza_1", 4],
			[ Item.ItemType.ITEM_CONSUMABLES, "soft_drink_1", 10],
		], 10
	)
