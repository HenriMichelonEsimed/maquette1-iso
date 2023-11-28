extends Control

class InventoryScreenState extends State:
	var tab:int = 0
	func _init():
		super("inventory_screen")

signal close(node:Node)
signal item_dropped(item:Item,quantity:int)
signal item_use(item:Item)

@onready var tabs:TabContainer = $Content/Body/Content/Tabs
@onready var list_tools:ItemList = $Content/Body/Content/Tabs/Tools/List
@onready var list_consumables:ItemList = $Content/Body/Content/Tabs/Consumables/List
@onready var list_quest:ItemList = $Content/Body/Content/Tabs/Quests/List
@onready var list_miscellaneous:ItemList = $Content/Body/Content/Tabs/Miscellaneous/List
@onready var item_content = $Content/Body/Content/PanelItem/Content
@onready var item_title = $Content/Body/Content/PanelItem/Content/Title
@onready var node_3d = $"Content/Body/Content/PanelItem/Content/ViewContent/3DView/InsertPoint"
@onready var panel_crafting = $Content/Body/Content/PanelCrafting
@onready var list_crafting = $Content/Body/Content/PanelCrafting/Content/ListCraft
@onready var button_dropcraft = $Content/Body/Content/PanelCrafting/Content/Actions/DropCraft
@onready var button_craft = $Content/Body/Content/PanelCrafting/Content/Actions/Craft
@onready var label_recipe = $Content/Body/Content/PanelCrafting/Content/VBoxContainer/LabelRecipe

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

var state = InventoryScreenState.new()
var item:Item
var list:ItemList
var prev_tab = -1
var crafting_items = []
var crafting_recipe = null
var crafting_target = null

func _ready():
	_resize()
	StateSaver.loadState(state)
	_refresh()
	if list_content[state.tab].item_count > 0:
		tabs.current_tab = state.tab
	connect("item_dropped", GameState.current_zone.on_item_dropped)

func _process(_delta):
	if select_dialog != null: return
	if Input.is_action_just_pressed("cancel") and panel_crafting.visible:
		_on_button_stop_craft_pressed()
		return
	elif Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("player_inventory"):
		_on_button_back_pressed()
		return
	if Input.is_action_just_pressed("delete"):
		_on_drop_pressed()
		return
	if Input.is_action_just_pressed("player_use_nomouse"):
		_on_use_pressed()
		return
	if Input.is_action_just_pressed("craft"):
		if panel_crafting.visible and (crafting_target != null):
			_on_crafting_pressed()
		else:
			_on_craft_pressed()
		return
	state.tab = tabs.current_tab
	if Input.is_action_just_pressed("ui_left"):
		state.tab -= 1
		_set_tab()
	elif Input.is_action_just_pressed("ui_right"):
		state.tab += 1
		_set_tab()

func _resize(with_crafting = false):
	panel_crafting.visible = with_crafting
	button_dropcraft.disabled = true
	button_craft.disabled = true
	var ratio = size.x / size.y
	var vsize = get_viewport().size / get_viewport().content_scale_factor
	size.x = vsize.x / (1.5 if vsize.x > 1200 else 1.2)
	size.y = size.x / ratio
	position.x = (vsize.x - size.x) / 2
	position.y = (vsize.y - size.y) / 2
	tabs.custom_minimum_size.x = size.x/(3 if with_crafting else 2)

func _on_button_back_pressed():
	_clear_crafting()
	close.emit(self)

func _on_list_tools_item_selected(index):
	list_consumables.deselect_all()
	list_miscellaneous.deselect_all()
	list_quest.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_TOOLS), index)

func _on_list_miscellaneous_item_selected(index):
	list_consumables.deselect_all()
	list_quest.deselect_all()
	list_tools.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_MISCELLANEOUS), index)

func _on_list_item_quest_selected(index):
	list_consumables.deselect_all()
	list_miscellaneous.deselect_all()
	list_tools.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_QUEST), index)

func _on_list_item_consumable_selected(index):
	list_miscellaneous.deselect_all()
	list_quest.deselect_all()
	list_tools.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_CONSUMABLES), index)

func _item_details(_item:Item, index):
	item = _item
	item_title.text = item.label
	Tools.show_item(_item, node_3d)
	item_content.visible = true

func _set_tab():
	if (state.tab < 0):
		state.tab = 3
	elif (state.tab > 3):
		state.tab = 0
	tabs.current_tab = state.tab

func _fill_list(type:Item.ItemType, list:ItemList):
	list.clear()
	for item in GameState.inventory.getall_bytype(type):
		list.add_item(tr(str(item)))

func _on_drop_pressed():
	if (item == null): return
	if (item is ItemMultiple) and (item.quantity > 1):
		select_dialog = Tools.load_dialog(self, "dialogs/select_quantity_dialog")
		select_dialog.open(item, false, tr("Drop"))
		select_dialog.connect("quantity", _drop)
		select_dialog.connect("close", _on_select_close)
	else:
		_drop()

func _on_select_close(node):
	select_dialog.queue_free()
	select_dialog = null
	_focus_current_tab()

func _drop(quantity:int=1):
	if (select_dialog != null):
		select_dialog.queue_free()
		select_dialog = null
	item_dropped.emit(item, quantity)
	_refresh()

func _refresh():
	item_content.visible = false
	_fill_lists()
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
	_focus_current_tab()
	state.tab = tab
	StateSaver.saveState(state)

func _fill_crafting_list():
	list_crafting.clear()
	for citem in crafting_items:
		list_crafting.add_item(tr(str(citem)))
	_resize(true)

func _fill_lists():
	for type in list_content: 
		_fill_list(type, list_content[type])

func _clear_crafting():
	for itm in crafting_items:
		GameState.inventory.add(itm)
	crafting_items.clear()

func _on_craft_pressed():
	if (item == null) or crafting_items.find(item) != -1: return
	var craft_item = item.duplicate()
	if (item.type == Item.ItemType.ITEM_TOOLS) or (item.type == Item.ItemType.ITEM_QUEST):
		item_content.visible = false
	else:
		craft_item.quantity = 1
		if (item.quantity == 1):
			item_content.visible = false
	crafting_items.push_back(craft_item)
	_fill_crafting_list()
	GameState.inventory.remove(craft_item)
	_fill_lists()
	var ingredients = []
	for i in crafting_items:
		ingredients.push_back(i.key)
	ingredients.sort()
	for i in CraftingRecipes.ingredients:
		if (item.key == i):
			var targets = CraftingRecipes.ingredients[i]
			for target in targets:
				var target_ingredients = CraftingRecipes.recipes[target][1]
				var have_recipe = target_ingredients == ingredients
				button_craft.disabled = not have_recipe
				label_recipe.text = "-"
				if have_recipe:
					crafting_target = Item.load(CraftingRecipes.recipes[target][0], target)
					if (crafting_target != null):
						crafting_recipe = target
						label_recipe.text = tr(str(crafting_target))
					else:
						button_craft.disabled = true
	_focus_current_tab()

func _on_button_stop_craft_pressed():
	_clear_crafting()
	list_crafting.clear()
	crafting_target = null
	_resize(false)
	_refresh()

func _on_drop_craft_pressed():
	if list_crafting.get_selected_items().size() == 0: return
	var selected = list_crafting.get_selected_items()[0]
	var craft_item = crafting_items[selected]
	crafting_items.remove_at(selected)
	GameState.inventory.add(craft_item)
	item_content.visible = false
	_fill_lists()
	if (crafting_items.is_empty()):
		_on_button_stop_craft_pressed()
	else:
		_fill_crafting_list()

func _on_list_craft_item_selected(index):
	button_dropcraft.disabled = false

func _on_crafting_pressed():
	if (crafting_target == null): return
	GameState.inventory.add(crafting_target)
	crafting_items.clear()
	list_crafting.clear()
	_resize(false)
	_refresh()

func _on_use_pressed():
	if (item == null): return
	item_use.emit(item)
	_on_button_back_pressed()
