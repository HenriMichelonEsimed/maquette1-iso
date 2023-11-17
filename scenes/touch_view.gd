extends Control

var analog_pressed = false
var analog_offset:Vector2
var analog_size:Vector2

signal view_rotate
signal view_zoomin
signal view_zoomout
@onready var move = $AnalogMove
@onready var move_position = $AnalogMove/Position
@onready var move_center = $AnalogMove/Center

var positions : Array = [Vector2(), Vector2()]
var left = false
var right = false
var forward = false
var backward = false
const diff = 2
var rotate = false
var zoomin = false
var zoomout = false

func _ready():
	if not GameState.is_mobile:
		queue_free()
	analog_size = move.texture_normal.get_size()
	
func _input(event):
	if event is InputEventScreenTouch:
		if rotate and not event.pressed:
			rotate = false
		

func _process(_delta):
	if analog_pressed:
		var touch_position : Vector2 = (move.get_local_mouse_position() - analog_offset).limit_length(analog_size.x / 2.0)
		move_position.position = touch_position + analog_size / 2.0
		var strength : Vector2 = touch_position / (analog_size / 2.0)
		left = strength.x < -diff
		right = strength.x >  diff
		forward = strength.y < -diff
		backward = strength.y >  diff
		if (left) : Input.action_press("view_left", 1)
		if (right) : Input.action_press("view_right", 1)
		if (forward) : Input.action_press("view_up", 1)
		if (backward) : Input.action_press("view_down", 1)
		#if not left and not right and not forward and not backward and not rotate:
		#	print(touch_position)
		#	rotate = true
		#	view_rotate.emit()
	if (zoomin):
		view_zoomin.emit()
	elif (zoomout):
		view_zoomout.emit()

func _on_analog_move_pressed():
	analog_offset = move.get_local_mouse_position()
	analog_pressed = true

func _on_analog_move_released():
	analog_pressed = false
	Input.action_release("view_down")
	Input.action_release("view_up")
	Input.action_release("view_left")
	Input.action_release("view_right")
	move_position.position = move_center.position

func _on_zoom_in_pressed():
	zoomin = true
	zoomout = false
	rotate = false

func _on_zoom_out_pressed():
	zoomin = false
	zoomout = true
	rotate = false

func _on_zoom_in_released():
	zoomin = false

func _on_zoom_out_released():
	zoomout = false

func _on_use_pressed():
	Input.action_press("player_use")

func _on_use_released():
	Input.action_release("player_use")
