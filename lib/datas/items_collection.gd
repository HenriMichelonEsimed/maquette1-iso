extends Node
class_name ItemsCollection

var items = []
var add_multiples:bool

func _init(_add:bool=true):
	add_multiples = _add

func new(type:int,_name:String):
	var item = load("res://props/items/" + Item.scenes_path[type] + "/" + _name + ".tscn")
	if (item != null) : add(item)

func add(item:Item):
	if add_multiples and (item is ItemMultiple):
		var found = items.filter(func(i): return i.key == item.key)
		if (found.size() > 0):
			found[0].quantity += item.quantity
			return
	items.push_back(item)
	
func remove(item:Item):
	if add_multiples and (item is ItemMultiple):
		var found = items.filter(func(i): return i.key == item.key)
		if (found.size() > 0):
			found[0].quantity -= item.quantity
			if (found[0].quantity > 0): return
	items.erase(item)
	
func getall_bytype(type:Item.ItemType) -> Array:
	return items.filter(func(item) : return item.type == type)
	
func getone_bytype(index:int, type:Item.ItemType) -> Item:
	return items.filter(func(item) : return item.type == type)[index]
	
func count():
	return items.size()

func saveState(file:FileAccess):
	file.store_64(items.size())
	for item in items:
		file.store_8(item.type)
		file.store_pascal_string(item.key)
		file.store_var(item.position)
		file.store_var(item.rotation)
		if item is ItemUnique:
			file.store_pascal_string(item.label)
			file.store_16(item.weight)
			file.store_8(item.wear)
		elif item is ItemMultiple:
			file.store_64(item.quantity)
	
func loadState(file:FileAccess):
	for i in range(file.get_64()):
		var type = file.get_8()
		var key = file.get_pascal_string()
		var path = 'res://props/items/' + Item.scenes_path[type] + '/' + key + '.tscn'
		var packed_scene = load(path)
		if (packed_scene == null):
			_skip_item(file, type)
			continue
		var item = packed_scene.instantiate()
		item.position = file.get_var()
		item.rotation = file.get_var()
		if (item is ItemUnique):
			item.label = file.get_pascal_string()
			item.weight = file.get_16()
			item.wear = file.get_8()
		elif (item is ItemMultiple):
			item.quantity = file.get_64()
		items.push_back(item)
		
func _skip_item(file:FileAccess, type:int):
	file.get_var()
	file.get_var()
	if (type in [Item.ItemType.ITEM_TOOLS, Item.ItemType.ITEM_CLOTHES]):
		file.get_pascal_string()
		file.get_16()
		file.get_8()
	else:
		file.get_64()
