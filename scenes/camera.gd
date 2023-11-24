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

func _ready():
	camera_pivot = get_node(cameraPivotPath)
	object_to_follow = get_node(objectToFollowPath)
	
func init():
	_size = GameState.camera.size
	if (_size == -1):
		_size = 20 #30 / get_viewport().content_scale_factor
	_view = GameState.camera.view
	_zoom_view()
	_rotate_view()

func move(pos):
	camera_pivot.position = pos


func _process(_delta):
	if (GameState.paused): return
	camera_pivot.position = object_to_follow.position
	if Input.is_action_just_released("view_rotate_left") or (Input.is_action_pressed("modifier") and Input.is_action_just_released("view_left")):
		_view += 1
		_rotate_view()
		return
	elif Input.is_action_just_released("view_rotate_right") or (Input.is_action_pressed("modifier") and Input.is_action_just_released("view_right")):
		_view -= 1
		_rotate_view()
		return
	if  Input.is_action_pressed("view_zoomin") or (Input.is_action_pressed("modifier") and Input.is_action_pressed("view_up")):
		_size -= 1
		_zoom_view()
	elif Input.is_action_just_pressed("view_zoomin"):
		_size -= 4
		_zoom_view()
	elif Input.is_action_just_pressed("view_zoomout") or Input.is_action_pressed("view_zoomout") or (Input.is_action_pressed("modifier") and Input.is_action_pressed("view_down")):
		_size += 1
		_zoom_view()
	elif Input.is_action_just_pressed("view_zoomout"):
		_size -= 4
		_zoom_view()
		
func _zoom_view():
	if (_size < 2): 
		_size = 2
	elif (_size > 100):
		_size = 100
	size = _size
	GameState.camera.size = _size

func _rotate_view():
	if (_view > 3): 
		_view = 0
	elif (_view < 0):
		_view = 3
	position = positions[_view]
	rotation_degrees = rotations[_view]
	GameState.camera.view = _view
	view_rotate.emit(_view)

func _on_view_pivot_view_moving():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_player_player_moving():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_touch_view_rotate():
	_view -= 1
	_rotate_view()

func _on_touch_view_view_zoomin():
	_size -= 1
	_zoom_view()

func _on_touch_view_view_zoomout():
	_size += 1
	_zoom_view()
