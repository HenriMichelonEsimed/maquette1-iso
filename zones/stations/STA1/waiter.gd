extends InteractiveCharacter
func d1():
	return ["Hello.", [
			["Hey, what's on the menu ?", _trade],
			r1,
			["Bye.", _end]
		]]

var r2: Array
var r5 = [
	["I'll look it up.", _end],
	r2
]

func d2():
	[ "I have 1 credit oranges if you're poor", r2 ]

func r1():
	var credits = GameState.inventory.get_credits_quantity()
	if (credits == 0) and GameState.quests.have_advpoint("main", "lvl0_make_first_purchase") and GameState.quests.have_advpoint("main", "lvl0_admin_woman_want_sandwitch"):
		return [ "Is there a way to negotiate?", d2]
	return null
	
func r4():
	var item = GameState.inventory.getitem(Item.ItemType.ITEM_QUEST, "ring_1")
	if item != null:
		return [tr("[Give %s]") % tr(item.label),
		[
			["Thank you ! Here is the access card", a1, item], [
				["Thank you.", _end]
			]
		]]
	else:
		return r5
	
func r3():
	if GameState.quests.have_advpoint("main", "lvl0_waiter_want_is_ring"):
		return [ "Did you find my ring?", [
		]]
	return null
	
func a1(): 
	GameState.quests.advpoint("main","lvl0_waiter_want_is_ring")

func _init():
	super(d1(),
		[
			[ Item.ItemType.ITEM_CONSUMABLES, "orange_1", 16],
			[ Item.ItemType.ITEM_CONSUMABLES, "ham_sandwich_1", 4],
			[ Item.ItemType.ITEM_CONSUMABLES, "burger_1", 8],
			[ Item.ItemType.ITEM_CONSUMABLES, "pizza_1", 4],
			[ Item.ItemType.ITEM_CONSUMABLES, "soft_drink_1", 10],
		], 10
	)
	r2 = [
		["The Administrator asks for a sandwich", [
			"The Administrator hasn't paid me my salary yet, she can go to hell", [
				[ "It's not very nice", d2]
			]
		]],
		["I'm starving and I'm out of credits",[
			"Find a job", [
				["Too exhausting", d2]
			]
		]],
		[ "Can we barter?", [
			["Someone stole my ring if you bring it back I can give you a ham sandwich", a1], [
				r5
			]
		]],
		#
	]
	if not GameState.quests.have_advpoint("main", "lvl0_generate_ham_sandwich"):
		if not items.have(Item.ItemType.ITEM_CONSUMABLES, "ham_sandwich_1"):
			items.new(Item.ItemType.ITEM_CONSUMABLES, "ham_sandwich_1")
		if not items.have(Item.ItemType.ITEM_CONSUMABLES, "burger_1"):
			items.new(Item.ItemType.ITEM_CONSUMABLES, "burger_1")
