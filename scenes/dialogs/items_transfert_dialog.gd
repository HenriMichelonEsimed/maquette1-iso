extends Control
class_name ItemsTransfertDialog

signal close(node:Storage)
signal item_collected(item:Item,quantity:int)
signal item_dropped(item:Item,quantity:int)
var list_container:ItemList
var list_inventory:ItemList
var current_list:ItemList
var storage:Storage
var transfered_item:Item

func _on_child_entered_tree(_node):
	connect("item_dropped", GameState.current_zone.on_item_dropped)
	connect("item_collected", GameState.current_zone.on_item_collected)

func _on_child_exiting_tree(_node):
	disconnect("item_dropped", GameState.current_zone.on_item_dropped)
	disconnect("item_collected", GameState.current_zone.on_item_collected)

func _process(_delta):
	if ($SelectQuantityDialog.visible): return
	if Input.is_action_just_pressed("cancel"):
		_on_close()
	elif Input.is_action_just_pressed("player_use"):
		_transfert()
	elif Input.is_action_just_pressed("collect_all"):
		_on_button_all_pressed()
		
func _transfert():
	if (current_list == list_container):
		for i in list_container.get_selected_items():
			var item = storage.get_items()[i];
			if (item is ItemMultiple) and (item.quantity > 1):
				open_select_quantity(item)
			else:
				container_to_inventory(item)
			break
	else:
		for i in list_inventory.get_selected_items():
			var item = GameState.inventory.getone(i)
			if (item is ItemMultiple) and (item.quantity > 1):
				open_select_quantity(item)
			else:
				inventory_to_container(item)
			break

func _on_button_all_pressed():
	for item in storage.get_items():
		container_to_inventory(item, -1, false)
	_on_close()

func open_select_quantity(item:Item):
	transfered_item = item
	$SelectQuantityDialog.open(item)

func _on_select_quantity_dialog_quantity(quantity):
	if (current_list == list_container):
		container_to_inventory(transfered_item,quantity)
	else:
		inventory_to_container(transfered_item,quantity)

func inventory_to_container(item:Item,quantity:int=-1,refresh:bool=true):
	item.set_meta("storage", storage)
	item_dropped.emit(item, quantity)
	if (refresh): _refresh()

func container_to_inventory(item:Item,quantity:int=-1,refresh:bool=true):
	item.set_meta("storage", storage)
	item_collected.emit(item,quantity)
	if (refresh): _refresh()

func open(node:Storage):
	list_container = $Content/VBoxContainer/Lists/ListContainer
	list_inventory = $Content/VBoxContainer/Lists/ListInventory
	storage = node
	current_list = list_container
	_refresh()
	
func _refresh():
	list_container.clear()
	list_inventory.clear()
	for item in storage.get_items():
		list_container.add_item(str(item))
	for item in GameState.inventory.getall():
		list_inventory.add_item(str(item))
	current_list.grab_focus()

func _on_close():
	close.emit(storage)

func _on_list_container_focus_entered():
	if ($SelectQuantityDialog.visible): 
		list_inventory.grab_focus()
		return
	current_list = list_container
	$Content/VBoxContainer/Lists/Buttons/Middle/ButtonDrop.visible = false
	$Content/VBoxContainer/Lists/Buttons/Middle/ButtonPick.visible = true
	
func _on_list_inventory_focus_entered():
	if ($SelectQuantityDialog.visible): return
	current_list = list_inventory
	$Content/VBoxContainer/Lists/Buttons/Middle/ButtonDrop.visible = true
	$Content/VBoxContainer/Lists/Buttons/Middle/ButtonPick.visible = false

