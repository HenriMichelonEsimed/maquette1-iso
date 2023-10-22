extends Usable

func _use():
	rotate(Vector3.UP, PI / 2)
	
func _unuse():
	rotate(Vector3.UP, -PI / 2)
