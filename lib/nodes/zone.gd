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
	for i in range(state.items_removed.size()):
		var item = get_node(state.items_removed[i])
		item.queue_free()
	for item in state.items_added.getall(): 
		if item.has_meta("storage_path"):
			var path = item.get_meta("storage_path").replace(str(get_path()) + "/", '')
			var parent = get_node(path)
			if (parent != null) and (parent is Storage):
				parent.add_child(item)
				item.set_meta("storage", parent)
				item.remove_meta("storage_path")
		else:
			add_child(item)
	for trigger in find_children("*", "ZoneChangeTrigger", true, true):
		trigger.connect("triggered", on_zone_change)
	var event = GameState.events_queue.getNextEvent(zone_name)
	while (event != null):
		var node = get_node(event.target)
		if (node != null):
			node.call(event.event)
		event = GameState.events_queue.getNextEvent(zone_name)
	_zone_ready()

func _zone_ready():
	pass

func on_zone_change(trigger:ZoneChangeTrigger):
	change_zone.emit(trigger.zone_name, trigger.spawnpoint_key)

func on_item_dropped(item:Item,quantity:int):
	var new_item = item.duplicate()
	new_item.position = GameState.player.global_position
	if (item is ItemMultiple):
		new_item.quantity = quantity
		GameState.inventory.remove(new_item)
	else:
		GameState.inventory.remove(item)
	if (item.has_meta("storage")):
		var storage = item.get_meta("storage")
		storage.add_child(new_item)
		var drop_point = storage.find_child("DropPoint")
		if (drop_point != null):
			new_item.position = drop_point.position
			new_item.rotation = drop_point.rotation
		new_item.disable()
	else:
		add_child(new_item)
		new_item.enable()
	state.items_added.add(new_item)

func on_item_collected(item:Item,quantity:int):
	var new_item = item.duplicate()
	new_item.remove_meta("storage")
	new_item.disable()
	if (quantity > 0 and (item is ItemMultiple) and (item.quantity != quantity)):
		new_item.quantity = quantity
		var old_item = item.duplicate()
		old_item.quantity -= quantity
		if (item.owner != null):
			state.items_removed.append(item.get_path())
		state.items_added.add(old_item)
		if (item.has_meta("storage")):
			item.get_meta("storage").add_child(old_item)
		else:
			add_child(old_item)
	else:
		if (item.owner != null): # items from scene
			state.items_removed.append(item.get_path())
	if (item.get_parent() != null): item.get_parent().remove_child(item)
	state.items_added.remove(item)
	GameState.inventory.add(new_item)
