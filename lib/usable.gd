extends StaticBody3D
class_name Usable

var is_used:bool = false
var save:bool

func _init(_save:bool = false):
	save = _save

func use():
	if (!is_used):
		_use()
		is_used = true
		
func _use():
	pass
