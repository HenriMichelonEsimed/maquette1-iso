extends Node3D
class_name ViewPivot

signal view_moving()
const player_maxdistance = Vector3(50.0, 0, 50.0)
const mouse_delta = 0

var current_view = 0
var signaled = false
var player_moving = false
var mouse_pressed_position = Vector2.ZERO
var mouse_previous_position = Vector2.ZERO
var mouse_vector:Vector2

func _input(event):
	if event is InputEventMouseMotion and mouse_pressed_position != Vector2.ZERO:
		mouse_vector = event.relative
#	if event is InputEventScreenTouch:
#		if( event.pressed):
#			mouse_pressed_position = event.position
#		else:
#			mouse_pressed_position = Vector2.ZERO
#			mouse_vector = Vector2.ZERO
#	if event is InputEventScreenDrag:
#		print(event.relative)
#		print(event.velocity)
#		mouse_vector = event.relative
#	#else:
#	#	mouse_vector = Vector2.ZERO

func _process(_delta):
	if (GameState.paused): return
	if Input.is_action_pressed("modifier") or player_moving : return
	var mouse_pos = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("view_pan"):
		mouse_pressed_position = mouse_pos
	elif Input.is_action_just_released("view_pan"):
		mouse_pressed_position = Vector2.ZERO
		mouse_vector = Vector2.ZERO
	elif (mouse_previous_position == mouse_pos):
		mouse_vector = Vector2.ZERO
	else:
		mouse_previous_position = mouse_pos
	
	var new_pos = position
	var modifier
	if (GameState.is_mobile):
		modifier = 1
	else:
		modifier = ((100 - GameState.camera.size)+5)/20.0
	if Input.is_action_pressed("view_right") or mouse_vector.x < -mouse_delta:
		new_pos.x += Player.directions["right"][current_view].x/modifier
		new_pos.z += Player.directions["right"][current_view].z/modifier
	if Input.is_action_pressed("view_left") or mouse_vector.x > mouse_delta:
		new_pos.x += Player.directions["left"][current_view].x/modifier
		new_pos.z += Player.directions["left"][current_view].z/modifier
	if Input.is_action_pressed("view_down") or mouse_vector.y < -mouse_delta:
		new_pos.x += Player.directions["backward"][current_view].x/modifier
		new_pos.z += Player.directions["backward"][current_view].z/modifier
	if Input.is_action_pressed("view_up") or mouse_vector.y > mouse_delta:
		new_pos.x += Player.directions["forward"][current_view].x/modifier
		new_pos.z += Player.directions["forward"][current_view].z/modifier
	var player_pos = GameState.player.position
	if (new_pos.x < (player_pos.x - player_maxdistance.x)):
		new_pos.x = player_pos.x - player_maxdistance.x
	if (new_pos.x > (player_pos.x + player_maxdistance.x)):
		new_pos.x = player_pos.x + player_maxdistance.x
	if (new_pos.z < (player_pos.z - player_maxdistance.z)):
		new_pos.z = player_pos.z - player_maxdistance.z
	if (new_pos.z > (player_pos.z + player_maxdistance.z)):
		new_pos.z = player_pos.z + player_maxdistance.z
	if (position != new_pos):
		position = new_pos
		if (!signaled) :
			view_moving.emit()
			signaled = true

func _on_camera_view_rotate(view:int):
	current_view = view

func _on_player_player_moving():
	signaled = false
	player_moving = true
	
func _on_player_player_stopmoving():
	player_moving = false
