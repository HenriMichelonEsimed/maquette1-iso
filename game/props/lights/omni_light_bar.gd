@tool
extends Node3D

@export var color:Color = Color(Color.WHITE)

func _ready():
	set_color(color)

func set_color(new_color:Color):
	$Support/Neon/Light/OmniLight3D.light_color = new_color
	$Support/Neon/Light.material = StandardMaterial3D.new()
	$Support/Neon/Light.material.albedo_color = new_color
	$Support/Neon/Light.material.shading_mode = 0
