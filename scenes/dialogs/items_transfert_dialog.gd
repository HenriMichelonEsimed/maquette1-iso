extends Control
class_name ItemsTransfertDialog

signal close
signal item_collected(item:Item)
signal item_dropped(item:Item)
var list_container:ItemList
var list_inventory:ItemList
var current_list:ItemList
var storage:Storage
var container2inventory:bool
var transfered_item:Item

func _ready():
	connect("item_dropped", GameState.current_zone.on_item_dropped)
	connect("item_collected", GameState.current_zone.on_item_collected)

func _on_child_exiting_tree(node):
	disconnect("item_dropped", GameState.current_zone.on_item_dropped)
	disconnect("item_collected", GameState.current_zone.on_item_collected)

func _process(delta):
	if Input.is_action_just_pressed("cancel"):
		_on_close()
	if Input.is_action_just_pressed("player_use"):
		_transfert()
		
func _transfert():
	if (list_container.has_focus()):
		for i in list_container.get_selected_items():
			var item = storage.items.items[i];
			if (item is ItemMultiple):
				container2inventory = true
				transfered_item = item
				$SelectQuantityDialog.open(item)
			else:
				container_to_inventory(item)
			break
	else:
		for i in list_inventory.get_selected_items():
			var item = GameState.inventory.getone(i)
			if (item is ItemMultiple):
				container2inventory = false
				transfered_item = item
				$SelectQuantityDialog.open(item)
			else:
				inventory_to_container(item)
			break
	
func _on_select_quantity_dialog_drop(quantity):
	if (transfered_item.quantity == quantity):
		if (container2inventory):
			container_to_inventory(transfered_item)
		else:
			inventory_to_container(transfered_item)
		return
	var item = transfered_item.duplicate()
	item.quantity = quantity
	if (container2inventory):
		if (transfered_item.owner != null):
			var new_container_item =  transfered_item.duplicate()
			transfered_item.set_meta("storage", storage.get_path())
			item_collected.emit(transfered_item)
			new_container_item.set_meta("storage", storage.get_path())
			new_container_item.quantity -= quantity
			new_container_item.disable()
			item_dropped.emit(new_container_item)
			GameState.inventory.add(item)
			item.enable()
			item_collected.emit(item)
			storage.remove_child(item)
			storage.items.remove(item)
			_refresh()
		else:
			container_to_inventory(item)
	else:
		GameState.inventory.remove(item)
		item.set_meta("storage", storage.get_path())
		storage.add_child(item)
		storage.items.add(item)
		item_dropped.emit(item)
		item.disable()
		_refresh()

func inventory_to_container(item:Item):
	var new_item = item.duplicate()
	GameState.inventory.remove(item)
	new_item.set_meta("storage", storage.get_path())
	storage.add_child(new_item)
	storage.items.add(new_item)
	item_dropped.emit(new_item)
	new_item.disable()
	_refresh()
	
func container_to_inventory(item:Item):
	item.enable()
	GameState.inventory.add(item.duplicate())
	item_collected.emit(item)
	if (item.owner != null):
		item.set_meta("storage", storage.get_path())
		item.owner = null
	storage.remove_child(item)
	storage.items.remove(item)
	_refresh()
		
func open(node:Storage):
	list_container = $Content/VBoxContainer/Lists/ListContainer
	list_inventory = $Content/VBoxContainer/Lists/ListInventory
	storage = node
	current_list = list_container
	_refresh()
	
func _refresh():
	list_container.clear()
	list_inventory.clear()
	for item in storage.items.items:
		list_container.add_item(str(item))
	for item in GameState.inventory.items:
		list_inventory.add_item(str(item))
	current_list.grab_focus()

func _on_close():
	list_container.clear()
	list_inventory.clear()
	close.emit()

func _on_list_container_focus_entered():
	current_list = list_container
	
func _on_list_inventory_focus_entered():
	current_list = list_inventory

