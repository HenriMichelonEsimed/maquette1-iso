extends Node3D

func set_color(new_color:Color):
	$Support/Neon/Light/OmniLight3D.light_color = new_color
	$Support/Neon/Light.material = StandardMaterial3D.new()
	$Support/Neon/Light.material.albedo_color = new_color
	$Support/Neon/Light.material.shading_mode = 0
