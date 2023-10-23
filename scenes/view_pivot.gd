extends Node3D
class_name ViewPivot

var current_view = 0

func _process(delta):
	if Input.is_action_pressed("view_modifier"): return
	if Input.is_action_pressed("view_right"):
		position.x += Player.directions["right"][current_view].x
		position.z += Player.directions["right"][current_view].z
	if Input.is_action_pressed("view_left"):
		position.x += Player.directions["left"][current_view].x
		position.z += Player.directions["left"][current_view].z
	if Input.is_action_pressed("view_down"):
		position.x += Player.directions["backward"][current_view].x
		position.z += Player.directions["backward"][current_view].z
	if Input.is_action_pressed("view_up"):
		position.x += Player.directions["forward"][current_view].x
		position.z += Player.directions["forward"][current_view].z
		
func _on_camera_view_rotate(view:int):
	current_view = view
