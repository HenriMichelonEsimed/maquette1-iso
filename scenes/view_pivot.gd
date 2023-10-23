extends Node3D
class_name ViewPivot

var current_view = 0
var mouse_margin = 50

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(delta):
	if Input.is_action_pressed("view_modifier"): return
	var pos = get_viewport().get_mouse_position()
	if Input.is_action_pressed("view_right") or (pos.x > (get_viewport().size.x - mouse_margin) and (pos.x < get_viewport().size.x+mouse_margin)):
		position.x += Player.directions["right"][current_view].x
		position.z += Player.directions["right"][current_view].z
	if Input.is_action_pressed("view_left") or (pos.x < mouse_margin and pos.x > -mouse_margin):
		position.x += Player.directions["left"][current_view].x
		position.z += Player.directions["left"][current_view].z
	if Input.is_action_pressed("view_down") or (pos.y > (get_viewport().size.y - mouse_margin)and (pos.y < get_viewport().size.y+mouse_margin)):
		position.x += Player.directions["backward"][current_view].x
		position.z += Player.directions["backward"][current_view].z
	if Input.is_action_pressed("view_up") or (pos.y < mouse_margin and pos.y > -mouse_margin):
		position.x += Player.directions["forward"][current_view].x
		position.z += Player.directions["forward"][current_view].z

func _on_camera_view_rotate(view:int):
	current_view = view
