extends Control

signal close(node:Node)

func _ready():
	_fill_list($VBoxContainer/Tabs/Tools/List, Item.ItemType.ITEM_TOOL)
	_fill_list($VBoxContainer/Tabs/Clothes/List, Item.ItemType.ITEM_CLOTHES)
	_fill_list($VBoxContainer/Tabs/Consumables/List, Item.ItemType.ITEM_CONSUMABLES)
	_fill_list($VBoxContainer/Tabs/Ammunitions/List, Item.ItemType.ITEM_AMMUNITIONS)
	_fill_list($VBoxContainer/Tabs/Miscellaneous/List, Item.ItemType.ITEM_MISCELLANEOUS)
		
func _on_button_back_pressed():
	close.emit(self)

func _process(_delta):
	if (Input.is_action_just_pressed("cancel")):_on_button_back_pressed()

func _fill_list(list:ItemList, type:Item.ItemType):
	for entry in PlayerInventory.get_bytype(type):
		list.add_item(str(entry.quantity))
		list.add_item(entry.item.label)
		if (entry.item is ItemCanWearOut):
			list.add_item(str(100 - entry.item.wear) + '%')
