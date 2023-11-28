extends Control

class TradeScreenState extends State:
	var tab:int = 0
	func _init():
		super("trade_screen")

signal trade_end(node:Node)

@onready var tabs:TabContainer = $Content/Body/Content/Tabs
@onready var list_tools:ItemList = $Content/Body/Content/Tabs/Tools/List
@onready var list_consumables:ItemList = $Content/Body/Content/Tabs/Consumables/List
@onready var list_quest:ItemList = $Content/Body/Content/Tabs/Quests/List
@onready var list_miscellaneous:ItemList = $Content/Body/Content/Tabs/Miscellaneous/List
@onready var item_content = $Content/Body/Content/PanelItem/Content
@onready var item_title = $Content/Body/Content/PanelItem/Content/Title
@onready var weigth_value = $Content/Body/Content/PanelItem/Content/LabelWeight
@onready var price_value = $Content/Body/Content/PanelItem/Content/LabelPrice
@onready var node_3d = $"Content/Body/Content/PanelItem/Content/ViewContent/3DView/InsertPoint"
@onready var label_credits = $Content/Bottom/Menu/Label
var alert_dialog = null
var select_dialog = null

const tab_order = [ 
	Item.ItemType.ITEM_TOOLS, 
	Item.ItemType.ITEM_CONSUMABLES,
	Item.ItemType.ITEM_MISCELLANEOUS,
	Item.ItemType.ITEM_QUEST
]

@onready var list_content = {
	Item.ItemType.ITEM_TOOLS : list_tools,
	Item.ItemType.ITEM_CONSUMABLES : list_consumables,
	Item.ItemType.ITEM_MISCELLANEOUS : list_miscellaneous,
	Item.ItemType.ITEM_QUEST : list_quest
}

var state = TradeScreenState.new()
var trader:InteractiveCharacter
var item:Item
var list:ItemList
var selected = 0
var credits = 0
var item_credits:ItemMiscellaneous
var prev_tab = -1

func open(char:InteractiveCharacter):
	trader = char
	item_credits = GameState.inventory.get_credits()
	if (item_credits != null):
		credits = item_credits.quantity
	_refresh()
	_hide_empty_tabs()

func _ready():
	var ratio = size.x / size.y
	var vsize = get_viewport().size / get_viewport().content_scale_factor
	size.x = vsize.x / (1.5 if vsize.x > 1200 else 1.2)
	size.y = size.x / ratio
	position.x = (vsize.x - size.x) / 2
	position.y = (vsize.y - size.y) / 2
	tabs.custom_minimum_size.x = size.x/2
	StateSaver.loadState(state)

func _process(_delta):
	if select_dialog != null or alert_dialog != null: return
	if Input.is_action_just_pressed("cancel"):
		_on_button_back_pressed()
		return
	elif Input.is_action_just_pressed("player_use_nomouse"):
		_on_buy_pressed()
		return
	state.tab = tabs.current_tab
	if Input.is_action_just_pressed("ui_left"):
		_prev_tab()
	elif Input.is_action_just_pressed("ui_right"):
		_next_tab()

func _on_button_back_pressed():
	trade_end.emit(self)

func _on_list_tools_item_selected(index):
	list_consumables.deselect_all()
	list_miscellaneous.deselect_all()
	list_quest.deselect_all()
	_item_details(trader.items.getone_bytype(index, Item.ItemType.ITEM_TOOLS), index)

func _on_list_miscellaneous_item_selected(index):
	list_consumables.deselect_all()
	list_quest.deselect_all()
	list_tools.deselect_all()
	_item_details(trader.items.getone_bytype(index, Item.ItemType.ITEM_MISCELLANEOUS), index)

func _on_list_item_quest_selected(index):
	list_consumables.deselect_all()
	list_miscellaneous.deselect_all()
	list_tools.deselect_all()
	_item_details(trader.items.getone_bytype(index, Item.ItemType.ITEM_QUEST), index)

func _on_list_item_consumable_selected(index):
	list_miscellaneous.deselect_all()
	list_quest.deselect_all()
	list_tools.deselect_all()
	_item_details(trader.items.getone_bytype(index, Item.ItemType.ITEM_CONSUMABLES), index)

func _item_details(_item:Item, index):
	selected = index
	item = _item
	item_title.text = item.label
	weigth_value.text = tr("Weigth : %.2f") % _item.weight
	price_value.text = tr("Unit price : %.2f") % _item.price
	Tools.show_item(_item, node_3d)
	item_content.visible = true

func _next_tab():
	for idx in range(tabs.current_tab+1, tabs.get_tab_count()):
		if not tabs.is_tab_hidden(idx): 
			tabs.current_tab = idx
			return

func _prev_tab():
	for idx in range(tabs.current_tab-1, -1, -1):
		if not tabs.is_tab_hidden(idx): 
			tabs.current_tab = idx
			return

func _fill_list(idx: int, type:Item.ItemType, list:ItemList):
	list.clear()
	for item in trader.items.getall_bytype(type):
		list.add_item(tr(str(item)))
	if (list.item_count == 0):
		tabs.set_tab_hidden(idx, true)
		
func _hide_empty_tabs():
	for i in range(0, tabs.get_tab_count()):
		if not tabs.is_tab_hidden(i):
			state.tab = i
			break
	tabs.current_tab = state.tab

func _refresh():
	item_content.visible = false
	label_credits.text =tr("Inventory : %d credits" if credits > 1 else "Inventory : %d credit")  % credits
	var idx = 0
	for type in list_content: 
		_fill_list(idx, type, list_content[type])
		idx += 1
	if (tabs.is_tab_hidden(tabs.current_tab)):
		_hide_empty_tabs()
	_focus_current_tab()

func _buy_quanity(value):
	return tr("%d (%d credits)") % [value, item.price * value]

func _on_buy_pressed():
	if (item == null): return
	if (item is ItemMultiple):
		select_dialog = Tools.load_dialog(self, "dialogs/select_quantity_dialog")
		select_dialog.open(item, false, tr("Buy"), _buy_quanity)
		select_dialog.connect("quantity", _buy)
		select_dialog.connect("close", _on_select_close)
	else:
		_buy()

func _buy(quantity:int=0):
	if (select_dialog != null):
		select_dialog.queue_free()
		select_dialog = null
	var price = quantity * item.price
	if price > credits:
		alert_dialog = Tools.load_dialog(self, "dialogs/alert_dialog")
		alert_dialog.open("Buy", "You don't have enough credits")
		alert_dialog.connect("close", _on_alert_close)
		return
	if (price > 0):
		credits -= price
		var remove_credit = item_credits.duplicate()
		remove_credit.quantity = price
		GameState.inventory.remove(remove_credit)
	var buy_item
	if (item.type == Item.ItemType.ITEM_MISCELLANEOUS) or (item.type == Item.ItemType.ITEM_CONSUMABLES):
		buy_item = item.duplicate()
		buy_item.quantity = quantity
	else:
		buy_item = item
	GameState.inventory.add(buy_item)
	trader.items.remove(buy_item)
	GameState.quests.event_all(Quest.QuestEventType.QUESTEVENT_BUY, item.key)
	_refresh()

func _on_select_close(node):
	select_dialog.queue_free()
	select_dialog = null
	_focus_current_tab()

func _on_alert_close(node):
	alert_dialog = null
	_focus_current_tab()

func _focus_current_tab():
	list = list_content[tab_order[tabs.current_tab]]
	list.grab_focus()
	if (list.item_count > 0) and not list.is_anything_selected():
		list.select(0)
		list.item_selected.emit(0)	

func _on_tabs_tab_selected(tab):
	if (prev_tab == tab): return
	prev_tab = tab
	item_content.visible = false
	_focus_current_tab()
	state.tab = tab
	StateSaver.saveState(state)
