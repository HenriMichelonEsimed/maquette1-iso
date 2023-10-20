extends Node3D
class_name Zone

signal change_zone(zone_name:String, spawnpoint_name:String)
@export var zone_name:String
var state:State = null

func _init(_state=null):
	if (state != null): state = _state.new(self)

func _ready():
	if (state == null) : state = State.new(zone_name, self)
	StateSaver.loadState(state)
	_zone_ready()

func _zone_ready():
	pass
	
func _save():
	pass
	
func on_zone_change(zonechange:ZoneChange):
	save()
	change_zone.emit(zonechange.zone_name, zonechange.spawnpoint_key)
	pass

func save():
	if (state != null):
		_save()
		StateSaver.saveState(state)
		
