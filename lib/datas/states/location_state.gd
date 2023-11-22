extends State
class_name LocationState

var zone_name:String = "stations/STA1/level_1"
#var zone_name:String = "exteriors/EXT0/ext_0"
var position:Vector3 = Vector3.ZERO
var rotation:Vector3 = Vector3.ZERO

func _init():
	super("location")
