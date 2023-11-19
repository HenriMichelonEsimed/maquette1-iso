extends CharacterBody3D
class_name InteractiveCharacter

@export var label:String

func _ready():
	set_collision_layer_value(5, true)

func _to_string():
	return label
