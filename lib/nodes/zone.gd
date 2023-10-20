extends Node3D
class_name Zone

signal change_zone(zone_name:String, spawnpoint_name:String)
@export var zone_name:String
var state:ZoneState = null

func _init(_state:ZoneState=null):
	if (state != null): state = _state.new(self)

func _ready():
	if (state == null) : state = ZoneState.new(zone_name, self)
	StateSaver.loadState(state)
	for item_path in state.item_removed:
		get_node(item_path).queue_free()
	_zone_ready()

func _zone_ready():
	pass
	
func _save():
	pass
	
func on_zone_change(zonechange:ZoneChange):
	save()
	change_zone.emit(zonechange.zone_name, zonechange.spawnpoint_key)
	pass
	
func on_item_collected(item:Item):
	state.item_removed.push_back(item.get_path())
	item.queue_free()

func save():
	if (state != null):
		_save()
		StateSaver.saveState(state)
		
