@tool
extends StaticBody3D

@export var sign:Texture2D

func _ready():
	if (sign != null):
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = sign
		$Plane.set_surface_override_material(1, mat)

