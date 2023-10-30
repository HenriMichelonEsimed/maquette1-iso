extends Control

var analog_pressed = false
var analog_offset:Vector2
var analog_size:Vector2

@onready var move = $AnalogMove
@onready var move_position = $AnalogMove/Position
@onready var move_center = $AnalogMove/Center

var positions : Array = [Vector2(), Vector2()]
var left = false
var right = false
var forward = false
var backward = false

func _ready():
	if not GameState.is_mobile:
		queue_free()
	analog_size = move.texture_normal.get_size()

func _process(delta):
	if analog_pressed:
		var touch_position : Vector2 = (move.get_local_mouse_position() - analog_offset).limit_length(analog_size.x / 2.0)
		move_position.position = touch_position + analog_size / 2.0
		var strength : Vector2 = touch_position / (analog_size / 2.0)
		print(strength)
		left = strength.x < -0.2
		right = strength.x >  0.2
		forward = strength.y < -0.2
		backward = strength.y >  0.2
		if (left) : Input.action_press("player_left", 1)
		if (right) : Input.action_press("player_right", 1)
		if (forward) : Input.action_press("player_forward", 1)
		if (backward) : Input.action_press("player_backward", 1)

func _on_analog_move_pressed():
	analog_offset = move.get_local_mouse_position()
	analog_pressed = true

func _on_analog_move_released():
	analog_pressed = false
	Input.action_release("player_backward")
	Input.action_release("player_forward")
	Input.action_release("player_left")
	Input.action_release("player_right")
	move_position.position = move_center.position
