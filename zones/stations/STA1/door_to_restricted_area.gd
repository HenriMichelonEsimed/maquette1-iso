extends Usable

func _check_use() -> bool:
	var check = GameState.inventory.have(Item.ItemType.ITEM_TOOLS, "access_card_1")
	if not check: NotifiManager.notif("You need an access card")
	return check
