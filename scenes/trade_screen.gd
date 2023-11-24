extends Control

class TradeScreenState extends State:
	var tab:int = 0
	func _init():
		super("trade_screen")

signal trade_end(node:Node)
@onready var buttonBuy = $Content/Body/PanelItem/Content/Bottom/ButtonBuy
@onready var tabs = $Content/Body/PanelItem/Content/Tabs
@onready var list_tools:ItemList = $Content/Body/PanelItem/Content/Tabs/Tools/List
@onready var list_clothes:ItemList = $Content/Body/PanelItem/Content/Tabs/Clothes/List
@onready var list_consumables:ItemList = $Content/Body/PanelItem/Content/Tabs/Consumables/List
@onready var list_quest:ItemList = $Content/Body/PanelItem/Content/Tabs/Quests/List
@onready var list_miscellaneous:ItemList = $Content/Body/PanelItem/Content/Tabs/Miscellaneous/List

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

var state = TradeScreenState.new()
var trader:InteractiveCharacter

func _ready():
	var ratio = size.x / size.y
	var vsize = get_viewport().size / get_viewport().content_scale_factor
	size.x = vsize.x / (1.5 if vsize.x > 1200 else 1.2)
	size.y = size.x / ratio
	position.x = (vsize.x - size.x) / 2
	position.y = (vsize.y - size.y) / 2
	buttonBuy.disabled = true
	StateSaver.loadState(state)
	tabs.current_tab = state.tab

func open(char:InteractiveCharacter):
	trader = char
	for type in list_content: _fill_list(type, list_content[type])

func _process(_delta):
	if ($SelectQuantityDialog.visible): return
	if Input.is_action_just_pressed("cancel"):
		_on_button_back_pressed()
		return
	state.tab = tabs.current_tab
	if Input.is_action_just_pressed("ui_left"):
		state.tab -= 1
		_set_tab()
	elif Input.is_action_just_pressed("ui_right"):
		state.tab += 1
		_set_tab()
	elif Input.is_action_just_pressed("ui_down"):
		var list = tabs.get_current_tab_control().find_child("List")
		if (!list.has_focus()): 
			list.grab_focus()
			if (list.item_count > 0):
				list.select(0)
				list.item_selected.emit(0)

func _on_button_back_pressed():
	trade_end.emit(self)
	
func _set_tab():
	if (state.tab < 0):
		state.tab = 4
	elif (state.tab > 4):
		state.tab = 0
	tabs.current_tab = state.tab
	StateSaver.saveState(state)

func _fill_list(type:Item.ItemType, list:ItemList):
	list.clear()
	for item in trader.items.getall_bytype(type):
		list.add_item(tr(str(item)))
