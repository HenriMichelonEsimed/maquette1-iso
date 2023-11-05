extends StaticBody3D

@export var light_color:Color = Color("e6c42e")

func _ready():
	$omni_light_bar.set_color(light_color)
