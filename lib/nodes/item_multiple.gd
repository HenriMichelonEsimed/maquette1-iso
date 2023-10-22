extends Item
class_name ItemMultiple

@export var quantity:int = 1
	
func _to_string():
	return str(quantity) + " x " + label
