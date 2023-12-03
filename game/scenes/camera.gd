extends Camera3D
class_name ISOCamera

@export var cameraPivotPath: NodePath
@export var objectToFollowPath: NodePath

signal view_rotate(view:int)

const positions = [ Vector3(-50, 70, 50), Vector3(-50,70,-50), Vector3(50,70,-50),  Vector3(50,70,50) ]
const rotations = [ Vector3(-45, -45, 0), Vector3(-45,-135,0), Vector3(-45,-225,0), Vector3(-45,45,0) ]
const accel = 4
var camera_pivot
var object_to_follow
var _size = -1
var _view = 0
var player_moving = false
var zoom_in = false
var zoom_out = false

func _ready():
	camera_pivot = get_node(cameraPivotPath)
	object_to_follow = get_node(objectToFollowPath)
	
func init():
	_size = GameState.camera.size
	if (_size == -1):
		_size = 10 #30 / get_viewport().content_scale_factor
	_view = GameState.camera.view
	zoom_view()
	rotate_view()

func move(pos):
	camera_pivot.position = pos

func _unhandled_input(event):
	if (GameState.paused): return
	if (event is InputEventMouseButton) and (not event.pressed):
		if (event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			if (Input.is_action_pressed("modifier")):
				rotate_view(1)
			else:
				zoom_view(2)
		elif (event.button_index == MOUSE_BUTTON_WHEEL_UP):
			if (Input.is_action_pressed("modifier")):
				rotate_view(-1)
			else:
				zoom_view(-2)
		return
	if (event is InputEventJoypadMotion) and Input.is_action_pressed("modifier"):
		if (event.axis == JOY_AXIS_RIGHT_X):
			if (event.axis_value == 1):
				rotate_view(1)
			elif (event.axis_value == -1):
				rotate_view(-1)
		elif (event.axis == JOY_AXIS_RIGHT_Y):
			if (event.axis_value == -1):
				zoom_in = true
				zoom_out = false
			elif (event.axis_value == 1):
				zoom_out = true
				zoom_in = false
			else:
				zoom_in = false
				zoom_out = false
				
			
func _unhandled_key_input(event):
	if (event is InputEventKey) and Input.is_action_pressed("modifier"):
		if (event.physical_keycode == KEY_UP):
			if (event.pressed):
				zoom_in = true
			else:
				zoom_in = false
		elif (event.physical_keycode == KEY_DOWN):
			if (event.pressed):
				zoom_out = true
			else:
				zoom_out = false
		elif (event.physical_keycode == KEY_LEFT) and not event.pressed:
			rotate_view(-1)
		elif (event.physical_keycode == KEY_RIGHT) and not event.pressed:
			rotate_view(1)

func _process(_delta):
	if (GameState.paused): return
	camera_pivot.position = object_to_follow.position
	if (zoom_in): zoom_view(-1)
	if (zoom_out): zoom_view(1)

func zoom_view(delta:int=0):
	_size += delta
	if (_size < 2): 
		_size = 2
	elif (_size > 100):
		_size = 100
	size = _size
	GameState.camera.size = _size

func rotate_view(delta:int=0):
	_view += delta
	if (_view > 3): 
		_view = 0
	elif (_view < 0):
		_view = 3
	position = positions[_view]
	rotation_degrees = rotations[_view]
	GameState.camera.view = _view
	view_rotate.emit(_view)

func _on_view_pivot_view_moving():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_player_player_moving():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_touch_view_rotate():
	rotate_view(-1)

func _on_touch_view_view_zoomin():
	zoom_view(-1)

func _on_touch_view_view_zoomout():
	zoom_view(1)
