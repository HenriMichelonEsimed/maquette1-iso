extends StaticBody3D
class_name Trigger

var is_triggered = false
signal triggered(trigger:Trigger)

func _ready():
	set_collision_layer_value(4, true)
	
func trigger():
	if (!is_triggered):
		is_triggered = true
		triggered.emit(self)
