extends Control

var analog_pressed = false
var analog_offset:Vector2
var analog_size:Vector2

@onready var move = $AnalogMove
@onready var move_position = $AnalogMove/Position
@onready var move_center = $AnalogMove/Center

var positions : Array = [Vector2(), Vector2()]

func _ready():
	#if not OS.get_name() in ["android", "iOS"]:
	#	queue_free()
	analog_size = move.texture_normal.get_size()
	
func _input(event):
	if event is InputEventScreenTouch:
		positions[event.index] = event.position
		if event.index == 1:
			var zoom_amount = (positions[0] - positions[1]).length()
			print(zoom_amount)

func _process(delta):
	if analog_pressed:
		var touch_position : Vector2 = (move.get_local_mouse_position() - analog_offset).limit_length(analog_size.x / 2.0)
		move_position.position = touch_position + analog_size / 2.0
		var strength : Vector2 = touch_position / (analog_size / 2.0)
		print(strength)
		if (strength.x < -0.2) : Input.action_press("player_left", 1)
		if (strength.x >  0.2) : Input.action_press("player_right", 1)
		if (strength.y < -0.2) : Input.action_press("player_forward", 1)
		if (strength.y >  0.2) : Input.action_press("player_backward", 1)

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
