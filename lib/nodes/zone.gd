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
	for item in state.items_removed.items: 
		for node in find_children("*", "Item", true, true):
			if (node.type == item.type 
			and node.key == item.key 
			and node.position == node.position):
				node.queue_free()
	for item in state.items_added.items: 
		print(item.position)
		add_child(item)
	_zone_ready()

func _zone_ready():
	pass
	
func on_zone_change(zonechange:ZoneChange):
	change_zone.emit(zonechange.zone_name, zonechange.spawnpoint_key)
	
func on_item_dropped(item:Item):
	add_child(item)
	state.items_added.add(item)
	
func on_item_collected(item:Item):
	if (item.owner != null):
		remove_child(item)
		state.items_removed.add(item)
	else:
		state.items_added.remove(item)
		item.queue_free()
