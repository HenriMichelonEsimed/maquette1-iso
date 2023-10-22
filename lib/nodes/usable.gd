extends StaticBody3D
class_name Usable

signal using(is_used:bool)
@export var label:String
@export var save:bool = true

var is_used:bool = false
var animation:AnimationPlayer

func _init(_save:bool = true):
	save = _save
	
func _ready():
	if (label == null): label = get_path()
	animation = find_child("AnimationPlayer")
	set_collision_layer_value(3, true)

func use(startup:bool=false):
	if (!is_used):
		if (animation != null): 
			animation.play("use")
			if (startup): animation.seek(10)
		_use()
	else:
		if (animation != null): 
			animation.play_backwards("use")
			if (startup): animation.seek(10)
		_unuse()
	is_used = !is_used
	using.emit(is_used)
		
func _use():
	pass

func _unuse():
	pass

func _to_string():
	return label
