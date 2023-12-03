@tool
extends StaticBody3D

@export var wallpaper:Texture2D

func _ready():
	if (wallpaper != null):
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = wallpaper
		mat.backlight_enabled = true
		mat.backlight = Color.DARK_GRAY
		mat.disable_receive_shadows = true
		$"Monitor Samsung U28D590D/Screen".set_surface_override_material(0, mat)

