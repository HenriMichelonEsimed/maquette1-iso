extends Node3D
class_name ViewPivot

var current_view = 0
const mouse_margin = 50
const player_maxdistance = Vector3(100.0, 0, 100.0)

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	pass

func _process(delta):
	if Input.is_action_pressed("view_modifier"): return
	var mouse_pos = get_viewport().get_mouse_position()
	var new_pos = position
	if Input.is_action_pressed("view_right"):# or (mouse_pos.x > (get_viewport().size.x - mouse_margin) and (mouse_pos.x < get_viewport().size.x+mouse_margin)):
		new_pos.x += Player.directions["right"][current_view].x
		new_pos.z += Player.directions["right"][current_view].z
	if Input.is_action_pressed("view_left"):# or (mouse_pos.x < mouse_margin and mouse_pos.x > -mouse_margin):
		new_pos.x += Player.directions["left"][current_view].x
		new_pos.z += Player.directions["left"][current_view].z
	if Input.is_action_pressed("view_down"):# or (mouse_pos.y > (get_viewport().size.y - mouse_margin)and (mouse_pos.y < get_viewport().size.y+mouse_margin)):
		new_pos.x += Player.directions["backward"][current_view].x
		new_pos.z += Player.directions["backward"][current_view].z
	if Input.is_action_pressed("view_up"):# or (mouse_pos.y < mouse_margin and mouse_pos.y > -mouse_margin):
		new_pos.x += Player.directions["forward"][current_view].x
		new_pos.z += Player.directions["forward"][current_view].z
	var player_pos = GameState.player.position
	if (new_pos.x < (player_pos.x - player_maxdistance.x)):
		new_pos.x = player_pos.x - player_maxdistance.x
	if (new_pos.x > (player_pos.x + player_maxdistance.x)):
		new_pos.x = player_pos.x + player_maxdistance.x
	if (new_pos.z < (player_pos.z - player_maxdistance.z)):
		new_pos.z = player_pos.z - player_maxdistance.z
	if (new_pos.z > (player_pos.z + player_maxdistance.z)):
		new_pos.z = player_pos.z + player_maxdistance.z
	position = new_pos

func _on_camera_view_rotate(view:int):
	current_view = view
