extends Control

class InventoryScreenState extends State:
	var tab:int = 0
	func _init():
		super("inventory_screen")


signal close(node:Node)
var state = InventoryScreenState.new()

func _ready():
	StateSaver.loadState(state)
	$VBoxContainer/Tabs.current_tab = state.tab
	_fill_list($VBoxContainer/Tabs/Tools/List, Item.ItemType.ITEM_TOOL)
	_fill_list($VBoxContainer/Tabs/Clothes/List, Item.ItemType.ITEM_CLOTHES)
	_fill_list($VBoxContainer/Tabs/Consumables/List, Item.ItemType.ITEM_CONSUMABLES)
	_fill_list($VBoxContainer/Tabs/Ammunitions/List, Item.ItemType.ITEM_AMMUNITIONS)
	_fill_list($VBoxContainer/Tabs/Miscellaneous/List, Item.ItemType.ITEM_MISCELLANEOUS)
		
func _on_button_back_pressed():
	close.emit(self)
	queue_free()

func _process(_delta):
	if (Input.is_action_just_pressed("player_inventory")):
		_on_button_back_pressed()
		return
	state.tab = $VBoxContainer/Tabs.current_tab
	if Input.is_action_just_pressed("shortcut_left"):
		state.tab -= 1
	elif Input.is_action_just_pressed("shortcut_right"):
		state.tab += 1
	_set_tab()
		
func _set_tab():
	if (state.tab < 0):
		state.tab = 4
	elif (state.tab > 4):
		state.tab = 0
	$VBoxContainer/Tabs.current_tab = state.tab

func _fill_list(list:ItemList, type:Item.ItemType):
	for entry in GameState.inventory.get_bytype(type):
		list.add_item(str(entry.quantity))
		list.add_item(entry.item.label)
		if (entry.item is ItemUnique):
			list.add_item(str(100 - entry.item.wear) + '%')

func _on_tabs_tab_changed(tab):
	state.tab = tab
	StateSaver.saveState(state)

