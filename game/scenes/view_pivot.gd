extends Node3D
class_name ViewPivot

signal view_moving()
const player_maxdistance = Vector3(50.0, 0, 50.0)
const mouse_delta = 1

var current_view = 0
var signaled = false
var player_moving = false
var mouse_pressed_position = Vector2.ZERO
var mouse_vector:Vector2

func _process(_delta):
	if (GameState.paused): return
	if Input.is_action_pressed("modifier") or player_moving : return
	mouse_vector = Vector2.ZERO
	var mouse_pos =  get_viewport().get_mouse_position()
	if (mouse_pos.x >= (get_viewport().size.x - mouse_delta)):
		mouse_vector.x = -1
	elif (mouse_pos.x < mouse_delta):
		mouse_vector.x = 1
	if (mouse_pos.y >= (get_viewport().size.y - mouse_delta)):
		mouse_vector.y = -1
	elif (mouse_pos.y < mouse_delta):
		mouse_vector.y = 1
	
	var new_pos = position
	var modifier
	if (GameState.is_mobile):
		modifier = 1
	else:
		modifier = ((100 - GameState.camera.size)+5)/10.0
	if Input.is_action_pressed("view_right") or mouse_vector.x < 0:
		new_pos.x += Player.directions["right"][current_view].x/modifier
		new_pos.z += Player.directions["right"][current_view].z/modifier
	if Input.is_action_pressed("view_left") or mouse_vector.x > 0:
		new_pos.x += Player.directions["left"][current_view].x/modifier
		new_pos.z += Player.directions["left"][current_view].z/modifier
	if Input.is_action_pressed("view_down") or mouse_vector.y < 0:
		new_pos.x += Player.directions["backward"][current_view].x/modifier
		new_pos.z += Player.directions["backward"][current_view].z/modifier
	if Input.is_action_pressed("view_up") or mouse_vector.y > 0:
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
