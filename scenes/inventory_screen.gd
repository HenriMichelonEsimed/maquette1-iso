extends Control

class InventoryScreenState extends State:
	var tab:int = 0
	func _init():
		super("inventory_screen")

signal close(node:Node)
signal item_dropped(item:Item,quantity:int)

@export var tabs:TabContainer
@export var list_tools:ItemList
@export var list_clothes:ItemList
@export var list_consumables:ItemList
@export var list_quest:ItemList
@export var list_miscellaneous:ItemList

const tab_order = [ 
	Item.ItemType.ITEM_TOOLS, 
	Item.ItemType.ITEM_CLOTHES,
	Item.ItemType.ITEM_CONSUMABLES,
	Item.ItemType.ITEM_MISCELLANEOUS,
	Item.ItemType.ITEM_QUEST
]

@onready var list_content = {
	Item.ItemType.ITEM_TOOLS : list_tools,
	Item.ItemType.ITEM_CLOTHES : list_clothes,
	Item.ItemType.ITEM_CONSUMABLES : list_consumables,
	Item.ItemType.ITEM_MISCELLANEOUS : list_miscellaneous,
	Item.ItemType.ITEM_QUEST : list_quest
}
@onready var item_content = $Content/Body/Content/PanelItem/Content
@onready var item_title = $Content/Body/Content/PanelItem/Content/Title
@onready var weigth_value = $Content/Body/Content/PanelItem/Content/WeightLine/Value
@onready var node_3d = $"Content/Body/Content/PanelItem/Content/ViewContent/3DView/InsertPoint"

var state = InventoryScreenState.new()
var item:Item
var list:ItemList
var selected = 0

func _ready():
	var vsize = get_viewport().size / get_viewport().content_scale_factor
	size = vsize / 1.5
	position.x = (vsize.x - size.x) / 2
	position.y = (vsize.y - size.y) / 2
	tabs.custom_minimum_size.x = size.x/2
	StateSaver.loadState(state)
	tabs.current_tab = state.tab
	for type in list_content: _fill_list(type, list_content[type])
	connect("item_dropped", GameState.current_zone.on_item_dropped)

func _on_button_back_pressed():
	close.emit(self)
	queue_free()

func _on_list_tools_item_selected(index):
	list_clothes.deselect_all()
	list_consumables.deselect_all()
	list_miscellaneous.deselect_all()
	list_quest.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_TOOLS), index)

func _on_list_miscellaneous_item_selected(index):
	list_clothes.deselect_all()
	list_consumables.deselect_all()
	list_quest.deselect_all()
	list_tools.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_MISCELLANEOUS), index)

func _on_list_item_quest_selected(index):
	list_clothes.deselect_all()
	list_consumables.deselect_all()
	list_miscellaneous.deselect_all()
	list_tools.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_QUEST), index)

func _on_list_item_consumable_selected(index):
	list_clothes.deselect_all()
	list_miscellaneous.deselect_all()
	list_quest.deselect_all()
	list_tools.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_CONSUMABLES), index)

func _on_list_item_clothe_selected(index):
	list_miscellaneous.deselect_all()
	list_consumables.deselect_all()
	list_quest.deselect_all()
	list_tools.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_CLOTHES), index)

func _item_details(_item:Item, index):
	selected = index
	item = _item
	item_title.text = item.label
	weigth_value.text = str(item.weight)
	for c in node_3d.get_children():
		c.queue_free()
	var clone = _item.duplicate()
	node_3d.add_child(clone)
	clone.position = Vector3.ZERO
	clone.scale = clone.scale * clone.preview_scale
	item_content.visible = true

func _process(_delta):
	if ($SelectQuantityDialog.visible): return
	if (Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("player_inventory")):
		_on_button_back_pressed()
		return
	elif Input.is_action_just_pressed("delete"):
		_on_drop_pressed()
		return
	state.tab = tabs.current_tab
	if Input.is_action_just_pressed("shortcut_left"):
		state.tab -= 1
		_set_tab()
	elif Input.is_action_just_pressed("shortcut_right"):
		state.tab += 1
		_set_tab()
	elif Input.is_action_just_pressed("shortcut_down"):
		var list = tabs.get_current_tab_control().find_child("List")
		if (!list.has_focus()): 
			list.grab_focus()
			if (list.item_count > 0):
				list.select(0)
				list.item_selected.emit(0)

func _set_tab():
	if (state.tab < 0):
		state.tab = 4
	elif (state.tab > 4):
		state.tab = 0
	tabs.current_tab = state.tab
	item_content.visible = false
	StateSaver.saveState(state)

func _fill_list(type:Item.ItemType, list:ItemList):
	list.clear()
	for item in GameState.inventory.getall_bytype(type):
		list.add_item(str(item))

func _on_drop_pressed():
	if (item == null): return
	if (item is ItemMultiple):
		$SelectQuantityDialog.open(item, "Drop")
	else:
		_drop()
func _drop(quantity:int=0):
	item_dropped.emit(item, quantity)
	_refresh()

func _refresh():
	item_content.visible = false
	_fill_list(item.type, list_content[item.type])
	
func _on_tabs_tab_selected(tab):
	list = list_content[tab_order[tab]]
	if (tab == state.tab): return
	state.tab = tab
	StateSaver.saveState(state)

