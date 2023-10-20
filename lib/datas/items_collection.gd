extends Node
class_name ItemsCollection

@export var _entries = []

func add(item:Item):
	if (item.type in [ Item.ItemType.ITEM_CONSUMABLES, Item.ItemType.ITEM_AMMUNITIONS, Item.ItemType.ITEM_MISCELLANEOUS ]):
		var found = _entries.filter(func(entry): return entry.item.key == item.key)
		if (found.size() > 0):
			found[0].quantity += 1
			return
	_entries.push_back(ItemEntry.new(item, 1))
	
func get_bytype(type:Item.ItemType) -> Array:
	return _entries.filter(func(e) : return e.item.type == type)
	
func count():
	return _entries.size()

class ItemEntry:
	var item:Item
	var quantity:int
	func _init(_item, _qty):
		item = _item
		quantity = _qty
