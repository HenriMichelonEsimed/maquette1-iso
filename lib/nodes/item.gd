extends CharacterBody3D
class_name Item

enum ItemType {
	ITEM_TOOLS			= 0,
	ITEM_CONSUMABLES	= 1,
	ITEM_MISCELLANEOUS	= 2,
	ITEM_QUEST			= 3
	}
const scenes_path = [ 'tools', 'consum', 'misc', 'quest']

@export var key:String
@export var label:String
@export var price:float = 0.0
@export var type:ItemType
@export var preview_scale:float = 1.0

var fall_acceleration = 40
var target_velocity = Vector3.ZERO

func _ready():
	label = tr(label)
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	
static func load(type:int,_name:String):
	var item = load("res://props/items/" + Item.scenes_path[type] + "/" + _name + ".tscn")
	if (item != null):
		return item.instantiate()
	return null

func collect():
	return true

func disable():
	set_collision_layer_value(2, false)
	#visible = false
	
func enable():
	set_collision_layer_value(2, true)
	scale = Vector3(1.0, 1.0, 1.0)
	#visible = true
	
func _to_string():
	return label

