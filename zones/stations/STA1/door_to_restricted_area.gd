extends Usable

func _check_use() -> bool:
	var check = GameState.inventory.have(Item.ItemType.ITEM_TOOLS, "access_card_1")
	if not check: 
		NotifManager.notif("You need an access card")
		QuestsEvents.advpoint("lvl0_door_to_restricted_area_access_card")
	return check
