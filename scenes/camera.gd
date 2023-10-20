extends Camera3D

@export var cameraPivotPath: NodePath
@export var objectToFollowPath: NodePath

signal view_rotate(view:int)

const positions = [ Vector3(-50, 70, 50), Vector3(-50,70,-50), Vector3(50,70,-50),  Vector3(50,70,50) ]
const rotations = [ Vector3(-45, -45, 0), Vector3(-45,-135,0), Vector3(-45,-225,0), Vector3(-45,45,0) ]
const accel = 2
var camera_pivot
var object_to_follow
var state = CameraState.new()

func _ready():
	camera_pivot = get_node(cameraPivotPath)
	object_to_follow = get_node(objectToFollowPath)
	StateSaver.loadState(state)
	_zoom_view()
	_rotate_view()

func move(pos):
	camera_pivot.position = pos

func _process(delta):
	if (GameState.paused): return
	camera_pivot.position = camera_pivot.position.lerp(object_to_follow.position, delta * accel)
	if Input.is_action_pressed("view_zoomin") or Input.is_action_just_released("view_zoomin"):
		state.size -= 1
		_zoom_view()
	elif Input.is_action_pressed("view_zoomout") or Input.is_action_just_released("view_zoomout"):
		state.size += 1
		_zoom_view()
	if Input.is_action_just_released("view_rotate_left"):
		state.view += 1
		_rotate_view()
	elif Input.is_action_just_released("view_rotate_right"):
		state.view -= 1
		_rotate_view()
		
func _zoom_view():
	if (state.size < 10): 
		state.size = 10
	elif (state.size > 60):
		state.size = 60
	size = state.size
	StateSaver.saveState(state)

func _rotate_view():
	if (state.view > 3): 
		state.view = 0
	elif (state.view < 0):
		state.view = 3
	position = positions[state.view]
	rotation_degrees = rotations[state.view]
	view_rotate.emit(state.view)
	StateSaver.saveState(state)

class CameraState extends State:
	var size:int = 30
	var view:int = 0
	func _init():
		super("camera")
