extends Usable
class_name Storage

signal open(node:Storage)
var items=ItemsCollection.new()

func _init():
	super(false)

func _ready():
	set_collision_layer_value(3, true)
	for item in find_children("*", "Item"):
		item.set_collision_layer_value(2, false)
		item.visible = false
		items.add(item)
	
func _use():
	if (is_used):
		is_used = false
		open.emit(self)
