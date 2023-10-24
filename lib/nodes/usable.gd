extends StaticBody3D
class_name Usable

signal using(is_used:bool)
@export var label:String
@export var save:bool = true
@export var player_use = true

var is_used:bool = false
var animation:AnimationPlayer

func _init(_save:bool = true):
	save = _save
	
func _ready():
	if (label == null): label = get_path()
	animation = find_child("AnimationPlayer")
	if (animation != null):
		animation.connect("animation_finished", _on_animation_finished)
	set_collision_layer_value(3, true)

func use(byplayer:bool=false,startup:bool=false):
	if (!startup and !player_use and byplayer): return
	is_used = !is_used
	if (is_used):
		if (animation != null):
			animation.play("use")
			if (startup): animation.seek(10)
		else:
			_use()
			using.emit(is_used)
	else:
		if (animation != null): 
			animation.play_backwards("use")
			if (startup): animation.seek(10)
		else:
			_unuse()
			using.emit(is_used)

func _on_animation_finished(anim_name:String):
	if (anim_name == "use"):
		_use()
		using.emit(is_used)
	else:
		_unuse()
		using.emit(is_used)

func _use():
	pass

func _unuse():
	pass

func _to_string():
	return label
