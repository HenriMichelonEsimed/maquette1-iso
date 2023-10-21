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
	for item_path in state.items_removed: get_node(item_path).queue_free()
	for entry in state.items_added.entries: 
		add_child(entry.item)
	_zone_ready()

func _zone_ready():
	pass
	
func on_zone_change(zonechange:ZoneChange):
	change_zone.emit(zonechange.zone_name, zonechange.spawnpoint_key)
	
func on_item_dropped(item:Item):
	state.items_added.add(item)
	add_child(item)
	
func on_item_collected(item:Item):
	state.items_removed.push_back(item.get_path())
	item.queue_free()
