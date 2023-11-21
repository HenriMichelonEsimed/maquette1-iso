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
			["Give a sandwich to the Administrator"]
	}
)
