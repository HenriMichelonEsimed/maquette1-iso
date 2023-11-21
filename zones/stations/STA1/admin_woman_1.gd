extends InteractiveCharacter

var d1 = []

var r3 = [ "[Show message on phone]",
	[
		["Oh ok I see. But I am very hungry and very busy. If you can bring me a sandwitch I could help you", a3], [
			["Ok I'll look it up.", end],
			["...in your dreams!", d1],
		]
	]
]

var r2a =["Why do you need one ?", [
		["I need to see someone", 
			[
				"Who is \"someone\" ?", [
					[ "I don't know",
						[ 
							"Come back when you have a name", [
								["ok", end]
							]
						]
					],
					r3
				]
			]
		],
		["Just give me one",
			[
				"I don't even know who you are", [["Sure, but..", end]]
			]
		]
	]
]

var r2b = [ "Where is my sandwitch ?", [
			["I'll look it up.", end],
			["...in your dreams!", d1],
			r2d
		]
	]
	

func r2d():
	var item = GameState.inventory.getitem(Item.ItemType.ITEM_CONSUMABLES, "ham_sandwich_1")
	if item != null:
		return ["[Give %s]" % item.label, 
		[
			["Thank you ! Here is the access card", a1, item], [
				["Thank you.", end]
			]
		]]
	return null

func r2e():
	if GameState.quests.have_advpoint("main", "lvl0_admin_woman_want_sandwitch"):
		return r2b
	return r2a

var r2 = ["Where can I get an access card ?", 
	r2e
]

var r1 = ["How can I access the restricted area ?", 
	[
		["You need an access card", a2],  [
			r2
		]
	]
]

func a1(item): 
	GameState.inventory.remove(item)
	GameState.inventory.new(Item.ItemType.ITEM_QUEST, "access_card_1")
	GameState.quests.advpoint("main", "lvl0_admin_woman_give_access_card")

func a2(): 
	GameState.quests.advpoint("main","lvl0_admin_woman_have_access_card")

func a3(): 
	GameState.quests.advpoint("main","lvl0_admin_woman_want_sandwitch")

func r4():
	if not GameState.quests.have_advpoint("main", "lvl0_door_to_restricted_area_access_card"): return null
	if GameState.quests.have_advpoint("main", "lvl0_admin_woman_have_access_card"):
		if GameState.quests.have_advpoint("main", "lvl0_admin_woman_give_access_card"):
			return null
		else:
			return r2
	return r1


func _init():
	d1.append_array(["How can I help you ?", [
		["Who are you ?", [
			"I am the administrator of this station", [["Nice to meet you", d1]]
		]],
		r4,
		["Bye.", end]
	]])
	super(d1)
