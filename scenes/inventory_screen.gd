extends Control

class InventoryScreenState extends State:
	var tab:int = 0
	func _init():
		super("inventory_screen")

signal close(node:Node)
signal item_dropped(item:Item)

@export var tabs:TabContainer
@export var list_tools:ItemList
@export var list_clothes:ItemList
@export var list_consumables:ItemList
@export var list_ammunitions:ItemList
@export var list_miscellaneous:ItemList

const tab_order = [ 
	Item.ItemType.ITEM_TOOLS, 
	Item.ItemType.ITEM_CLOTHES,
	Item.ItemType.ITEM_CONSUMABLES,
	Item.ItemType.ITEM_AMMUNITIONS,
	Item.ItemType.ITEM_MISCELLANEOUS
]

@onready var list_content = {
	Item.ItemType.ITEM_TOOLS : list_tools,
	Item.ItemType.ITEM_CLOTHES : list_clothes,
	Item.ItemType.ITEM_CONSUMABLES : list_consumables,
	Item.ItemType.ITEM_AMMUNITIONS : list_ammunitions,
	Item.ItemType.ITEM_MISCELLANEOUS : list_miscellaneous
}
@onready var item_content = $Content/Body/Content/PanelItem/Content
@onready var item_title = $Content/Body/Content/PanelItem/Content/Title
@onready var weigth_value = $Content/Body/Content/PanelItem/Content/WeightLine/Value

var state = InventoryScreenState.new()
var item:Item
var list:ItemList
var selected = 0
var slide_pressed = 0

func _ready():
	StateSaver.loadState(state)
	tabs.current_tab = state.tab
	for type in list_content: _fill_list(type, list_content[type])
	connect("item_dropped", GameState.current_zone.on_item_dropped)
		
func _on_button_back_pressed():
	close.emit(self)
	queue_free()
	
func _on_list_tools_item_selected(index):
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_TOOLS), index)
	
func _on_list_miscellaneous_item_selected(index):
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_MISCELLANEOUS), index)
	
func _item_details(_item, index):
	selected = index
	item = _item
	item_title.text = item.label
	weigth_value.text = str(item.weight)
	item_content.visible = true

func _process(_delta):
	if ($DropDialog.visible):
		if (slide_pressed > 10):
			if Input.is_action_pressed("shortcut_left"):
				$DropDialog/Content/Body/SliderQuantity.value -= 1
			elif Input.is_action_pressed("shortcut_right"):
				$DropDialog/Content/Body/SliderQuantity.value += 1
		else :
			if Input.is_action_pressed("shortcut_left") or Input.is_action_pressed("shortcut_right"):
				slide_pressed += 1
		if Input.is_action_just_released("shortcut_left"):
			$DropDialog/Content/Body/SliderQuantity.value -= 1
			slide_pressed = 0
		elif Input.is_action_just_released("shortcut_right"):
			$DropDialog/Content/Body/SliderQuantity.value += 1
			slide_pressed = 0
		return
	if (Input.is_action_just_pressed("player_inventory")):
		_on_button_back_pressed()
		return
	if (Input.is_action_just_pressed("inventory_drop")):
		_on_drop_pressed()
	state.tab = tabs.current_tab
	if Input.is_action_just_pressed("shortcut_left"):
		state.tab -= 1
		_set_tab()
	elif Input.is_action_just_pressed("shortcut_right"):
		state.tab += 1
		_set_tab()
	elif Input.is_action_just_pressed("shortcut_down"):
		_next_item()
	elif Input.is_action_just_pressed("shortcut_up"):
		_previous_item()
	
func _next_item():
	if (list == null): return
	var index
	if (item == null):
		index = 0
	else:
		index = selected + 1
	if (index >= list.item_count): index = 0
	list.deselect_all()
	list.select(index)
	list.item_selected.emit(index)
	
func _previous_item():
	if (list == null): return
	var index
	if (item == null):
		index = list.item_count - 1
	else:
		index = selected - 1
	if (index < 0): index = list.item_count - 1
	list.deselect_all()
	list.select(index)
	list.item_selected.emit(index)
	
func _set_tab():
	if (state.tab < 0):
		state.tab = 4
	elif (state.tab > 4):
		state.tab = 0
	tabs.current_tab = state.tab
	StateSaver.saveState(state)
	#tabs.get_child(state.tab).get_child(0).grab_focus()

func _fill_list(type:Item.ItemType, list:ItemList):
	for item in GameState.inventory.getall_bytype(type):
		list.add_item(str(item))

func _on_drop_pressed():
	if (item == null): return
	if (item is ItemMultiple):
		$DropDialog/Content/Body/LabelName.text = item.label
		$DropDialog/Content/Body/SliderQuantity.max_value = item.quantity
		$DropDialog/Content/Body/SliderQuantity.value = item.quantity
		$DropDialog/Content/Body/LabelQuantity.text = str($DropDialog/Content/Body/SliderQuantity.value)
		$DropDialog.visible = true
	else:
		_drop()
		
func _drop():
	GameState.inventory.remove(item)
	list_content[item.type].clear()
	_fill_list(item.type, list_content[item.type])
	item_content.visible = false
	item.position = GameState.player.global_position
	#item.global_rotation = GameState.player.global_rotation
	item_dropped.emit(item)
	
func _on_tabs_tab_selected(tab):
	list = list_content[tab_order[tab]]
	if (tab == state.tab): return
	state.tab = tab
	StateSaver.saveState(state)

func _on_button_cancel_drop_pressed():
	$DropDialog.visible = false

func _on_button_drop_pressed():
	var qty = $DropDialog/Content/Body/SliderQuantity.value
	item = item.duplicate()
	item.quantity = qty
	_on_button_cancel_drop_pressed()
	_drop()

func _on_slider_quantity_value_changed(value):
	$DropDialog/Content/Body/LabelQuantity.text = str($DropDialog/Content/Body/SliderQuantity.value)
