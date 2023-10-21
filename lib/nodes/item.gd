extends CharacterBody3D
class_name Item

enum ItemType {
	ITEM_TOOLS			= 0,
	ITEM_CLOTHES 		= 1,
	ITEM_CONSUMABLES	= 2,
	ITEM_AMMUNITIONS	= 3,
	ITEM_MISCELLANEOUS	= 4
	}
const scenes_path = [ 'tools', 'clothes', 'consum', 'ammos', 'misc']

@export var key:String
@export var label:String
@export var weight:int
@export var indestructible = false
@export var type:ItemType

var fall_acceleration = 40
var target_velocity = Vector3.ZERO

func _ready():
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)

func _physics_process(delta):
	if (GameState.paused): return
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		velocity = target_velocity
		move_and_slide()
