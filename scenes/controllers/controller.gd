extends Control

signal close(node:Node)

func _ready():
	var ratio = size.x / size.y
	var vsize = get_viewport().size / get_viewport().content_scale_factor
	size.x = vsize.x / 1.2
	size.y = size.x / ratio
	position.x = (vsize.x - size.x) / 2
	position.y = (vsize.y - size.y) / 2
	
func _process(_delta):
	if Input.is_anything_pressed():
		_on_close()

func _on_close():
	close.emit(self)
