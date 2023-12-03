extends StaticBody3D
class_name Functional

var is_used:bool = false
var save:bool

func _init(_save:bool = false):
	save = _save
	
func use():
	if (!is_used):
		_use()
	else:
		_unuse()
	is_used = !is_used
		
func _use():
	pass

func _unuse():
	pass
