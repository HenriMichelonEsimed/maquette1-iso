extends Node
class_name ItemsCollection

var _items = []
var add_multiples:bool

func _init(_add:bool=true):
	add_multiples = _add
	
func have(type:Item.ItemType, key:String) -> bool:
	var result = _items.filter(func(it) : return it.type == type and it.key == key)
	return result.size() > 0

func getitem(type:Item.ItemType, key:String) -> Item:
	var result = _items.filter(func(it) : return it.type == type and it.key == key)
	if result.size() > 0:
		return result[0]
	return null

func new(type:int,_name:String, qty:int=1):
	var item = load("res://props/items/" + Item.scenes_path[type] + "/" + _name + ".tscn")
	if (item != null):
		for i in range(0, qty):
			add(item.instantiate())

func add(item:Item):
	if add_multiples and (item is ItemMultiple):
		var found = _items.filter(func(i): return i.key == item.key)
		if (found.size() > 0):
			item.quantity += found[0].quantity
			_items.erase(found[0])
	_items.push_back(item)
	
func remove(item:Item):
	if add_multiples and (item is ItemMultiple):
		var found = _items.filter(func(i): return i.key == item.key)
		if (found.size() > 0):
			found[0].quantity -= item.quantity
			if (found[0].quantity <= 0): 
				_items.erase(found[0])
			return
	_items.erase(item)
	
func getall() -> Array:
	return _items
	
func getall_bytype(type:Item.ItemType) -> Array:
	return _items.filter(func(item) : return item.type == type)
	
func getone(index:int) -> Item:
	return _items[index]
	
func getone_bytype(index:int, type:Item.ItemType) -> Item:
	return _items.filter(func(item) : return item.type == type)[index]
	
func count() -> int:
	return _items.size()

func saveState(file:FileAccess):
	file.store_64(_items.size())
	for item in _items:
		file.store_8(item.type)
		file.store_pascal_string(item.key)
		var is_stored = item.has_meta("storage")
		file.store_8(1 if is_stored else 0)
		if (is_stored):
			file.store_pascal_string(item.get_meta("storage").get_path())
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
		var is_stored = file.get_8() == 1
		if (is_stored):
			item.set_meta("storage_path", file.get_pascal_string())
		item.position = file.get_var()
		item.rotation = file.get_var()
		if (item is ItemUnique):
			item.label = file.get_pascal_string()
			item.weight = file.get_16()
			item.wear = file.get_8()
		elif (item is ItemMultiple):
			item.quantity = file.get_64()
		_items.push_back(item)
		
func _skip_item(file:FileAccess, type:int):
	file.get_var()
	file.get_var()
	if (type in [Item.ItemType.ITEM_TOOLS, Item.ItemType.ITEM_CLOTHES]):
		file.get_pascal_string()
		file.get_16()
		file.get_8()
	else:
		file.get_64()
