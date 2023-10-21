extends Node
class_name ItemsCollection

class ItemEntry:
	var item:Item
	var quantity:int
	func _init(_item, _qty):
		item = _item
		quantity = _qty

@export var entries = []

func add(item:Item):
	if (item.type in [ Item.ItemType.ITEM_CONSUMABLES, Item.ItemType.ITEM_AMMUNITIONS, Item.ItemType.ITEM_MISCELLANEOUS ]):
		var found = entries.filter(func(entry): return entry.item.key == item.key)
		if (found.size() > 0):
			found[0].quantity += 1
			return
	entries.push_back(ItemEntry.new(item, 1))
	
func remove(item:Item):
	for entry in entries:
		if (entry.item == item): 
			entries.erase(entry)
			return
	
func getall_bytype(type:Item.ItemType) -> Array:
	return entries.filter(func(e) : return e.item.type == type)
	
func getone_bytype(index:int, type:Item.ItemType) -> ItemEntry:
	return entries.filter(func(e) : return e.item.type == type)[index]
	
func count():
	return entries.size()

func saveState(file:FileAccess):
	file.store_64(entries.size())
	for entry in entries:
		file.store_64(entry.quantity)
		file.store_8(entry.item.type)
		file.store_pascal_string(entry.item.key)
		if entry.item is ItemUnique:
			file.store_pascal_string(entry.item.label)
			file.store_16(entry.item.weight)
			file.store_8(entry.item.wear)
	
func loadState(file:FileAccess):
	for i in range(file.get_64()):
		var qty = file.get_64()
		var type = file.get_8()
		var key = file.get_pascal_string()
		var path = 'res://props/items/' + Item.scenes_path[type] + '/' + key + '.tscn'
		var packed_scene = load(path)
		if (packed_scene == null):
			_skip_item(file, type)
			continue
		var item = packed_scene.instantiate()
		if (item is ItemUnique):
			item.label = file.get_pascal_string()
			item.weight = file.get_16()
			item.wear = file.get_8()
		entries.push_back(ItemEntry.new(item, qty))
		
func _skip_item(file:FileAccess, type:int):
	if (type in [Item.ItemType.ITEM_TOOLS, Item.ItemType.ITEM_CLOTHES]):
		file.get_pascal_string()
		file.get_16()
		file.get_8()
