extends Usable
class_name Storage

signal open(node:Storage)
var items:ItemsCollection

func _init():
	super(false)

func _ready():
	set_collision_layer_value(3, true)
	items = find_child("ItemsCollection")
	if (items != null):
		for item in items.find_children("*", "Item"):
			item.set_collision_layer_value(2, false)
			item.visible = false
			items.add(item)
	
func _use():
	if (is_used):
		is_used = false
		open.emit(self)
