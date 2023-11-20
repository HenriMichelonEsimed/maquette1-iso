extends InteractiveCharacter

var r3 = [ "[show message on phone]",
	[
		["Oh ok I see. Here is the access card", a1], [
			["Thank you.", end]
		]
	]
]

var r2 = ["Where can I get an access card ?", 
	[
		"Why do you need one ?", [
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
]

var r1 = ["How can I access the restricted area ?", 
	[
		["You need an access card", a2],  [
			r2
		]
	]
]

func a1(): 
	GameState.inventory.new(Item.ItemType.ITEM_TOOLS, "access_card_1")
	QuestsEvents.advpoint("lvl0_admin_woman_access_card_2")

func a2(): 
	QuestsEvents.advpoint("lvl0_admin_woman_access_card_1")

func r4():
	if not GameState.main_quest.have_advpoint("lvl0_door_to_restricted_area_access_card"): return null
	if GameState.main_quest.have_advpoint("lvl0_admin_woman_access_card_1"):
		if GameState.main_quest.have_advpoint("lvl0_admin_woman_access_card_2"):
			return null
		else:
			return r2
	return r1

func _init():
	var d1 = []
	d1.append_array(["How can I help you ?", [
		["Who are you ?", [
			"I am the administrator of this station", [["Nice to meet you", d1]]
		]],
		r4,
		["Bye.", end]
	]])
	super(d1)
