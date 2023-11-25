extends Quest
class_name MainQuest

func _init():
	super("main", QMain0.new(), "Main Quest",
	{
		"lvl0_door_to_restricted_area_access_card" : 
			["Find an access card"],
		"lvl0_admin_woman_have_access_card": 
			["Find where to get an access card", "lvl0_door_to_restricted_area_access_card"],
		"lvl0_use_access_card": 
			["Use the access card", "lvl0_admin_woman_have_access_card", "lvl0_admin_woman_want_sandwitch"],
		"lvl0_admin_woman_want_sandwitch": 
			["Give a sandwich or a burger with ham to the Administrator"],
		"lvl0_waiter_want_is_ring": 
			["Find the Waiter's ring"],
		"lvl0_generate_ham_sandwich":
			[""],
		"lvl0_make_first_purchase":
			[""]
	}
)

func _on_new_quest_event(type:Quest.QuestEventType, event_key:String):
	if (not have_advpoint("lvl0_make_first_purchase")) and (type == Quest.QuestEventType.QUESTEVENT_BUY):
		add_advpoint("lvl0_make_first_purchase")
