extends StaticBody3D
class_name ZoneChange

var is_triggered = false
signal triggered(zonechange:ZoneChange)
@export var zone_name:String
@export var spawnpoint_key:String

func trigger():
	if (!is_triggered):
		is_triggered = true
		triggered.emit(self)
		
