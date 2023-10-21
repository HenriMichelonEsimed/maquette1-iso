extends Control

class InventoryScreenState extends State:
	var tab:int = 0
	func _init():
		super("inventory_screen")

signal close(node:Node)

@export var tabs:TabContainer
@export var list_tools:ItemList
@export var list_clothes:ItemList
@export var list_consumables:ItemList
@export var list_ammunitions:ItemList
@export var list_miscellaneous:ItemList

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

func _ready():
	StateSaver.loadState(state)
	tabs.current_tab = state.tab
	for type in list_content: _fill_list(type, list_content[type])
		
func _on_button_back_pressed():
	close.emit(self)
	queue_free()
	
func _on_list_tools_item_selected(index):
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_TOOLS))
	
func _item_details(entry):
	item = entry.item
	item_title.text = item.label
	weigth_value.text = str(item.weight)
	item_content.visible = true

func _process(_delta):
	if (Input.is_action_just_pressed("player_inventory")):
		_on_button_back_pressed()
		return
	if (Input.is_action_just_pressed("inventory_drop")):
		_on_drop_pressed()
	state.tab = tabs.current_tab
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
	tabs.current_tab = state.tab
	#tabs.get_child(state.tab).get_child(0).grab_focus()

func _fill_list(type:Item.ItemType, list:ItemList):
	for entry in GameState.inventory.getall_bytype(type):
		list.add_item(str(entry.quantity), null, false)
		list.add_item(entry.item.label)

func _on_tabs_tab_changed(tab):
	state.tab = tab
	StateSaver.saveState(state)

func _on_drop_pressed():
	if (item == null): return
	print(GameState.inventory.count())
	GameState.inventory.remove(item)
	print(GameState.inventory.count())
	list_content[item.type].clear()
	_fill_list(item.type, list_content[item.type])
	item.position = GameState.player.position
	item.rotation = GameState.player.rotation
	GameState.current_scene.add_child(item)
	
