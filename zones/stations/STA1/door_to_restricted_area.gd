extends Usable

func _use():
	

func _check_use() -> bool:
	#var check = GameState.inventory.have(Item.ItemType.ITEM_QUEST, "access_card_1")
	#if not check: 
	#	NotifManager.notif(tr("You need an access card"))
	#	GameState.quests.advpoint("main", "lvl0_door_to_restricted_area_access_card")
	#else:
	#	GameState.quests.finish_advpoint("main", "lvl0_use_access_card")
	#return check
	return true
