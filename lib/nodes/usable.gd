extends StaticBody3D
class_name Usable

signal using(is_used:bool)
@export var label:String

var save:bool
var is_used:bool = false
var _animation:AnimationPlayer

func _init(_save:bool = true):
	save = _save
	
func _ready():
	set_collision_layer_value(3, true)
	if (label == null): 
		label = get_path()
	if $Top/Text != null:
		$Top/Text.text = label
	_animation = find_child("AnimationPlayer")
	if (_animation != null):
		_animation.connect("animation_finished", _on_animation_finished)

func use(_byplayer:bool=false,startup:bool=false):
	is_used = !is_used
	if (is_used):
		if (_animation != null):
			_animation.play("use")
			if (startup): _animation.seek(10)
		else:
			_use()
			using.emit(is_used)
	else:
		if (_animation != null): 
			_animation.play_backwards("use")
			if (startup): _animation.seek(10)
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
