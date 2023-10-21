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
	
func get_bytype(type:Item.ItemType) -> Array:
	return entries.filter(func(e) : return e.item.type == type)
	
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
	pass
	





