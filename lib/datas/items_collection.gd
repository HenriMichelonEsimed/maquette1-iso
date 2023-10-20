extends Node
class_name ItemsCollection

var entries =[]

func add(item:Item):
	if (item.type in [ Item.ItemType.ITEM_CONSUMABLES, Item.ItemType.ITEM_AMMUNITIONS, Item.ItemType.ITEM_MISCELLANEOUS ]):
		var found = entries.filter(func(entry): return entry.item.key == item.key)
		if (found.size() > 0):
			found[0].quantity += 1
			return
	entries.push_back(ItemEntry.new(item, 1))

class ItemEntry:
	var item:Item
	var quantity:int
	func _init(_item, _qty):
		item = _item
		quantity = _qty
