extends InteractiveCharacter

var r1_done = false

func _init():
	var r3 = [ "[show message on phone]",
		[
			"Oh ok I see. Here is the access card", [
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
					["You need an access card", func():r1_done=true],  [
						r2
					]
				]
			]
	super(["How can I help you ?", [
			["Who are you ?", [
				"I am the administrator of this station", [["Nice to meet you", end]]
			]],
			func():return r2 if r1_done else r1,
			["Bye.", end]
		]])
