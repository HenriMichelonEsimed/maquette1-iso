extends Camera3D

@export var cameraPivotPath: NodePath
@export var objectToFollowPath: NodePath
@onready var cameraPivot = get_node(cameraPivotPath)
@onready var objectToFollow = get_node(objectToFollowPath)
signal view_rotate(view:int)

var accel = 2
const defaultSize = 30
const positions = [ Vector3(-50, 70, 50), Vector3(-50,70,-50), Vector3(50,70,-50), Vector3(50,70,50) ]
const rotations = [ Vector3(-45, -45, 0), Vector3(-45,-135,0), Vector3(-45,-225,0), Vector3(-45,45,0) ]
var current_view = 0

func _ready():
	size = defaultSize
	_rotate_view(current_view)

func move(pos):
	cameraPivot.position = pos

func _process(delta):
	cameraPivot.position = cameraPivot.position.lerp(objectToFollow.position, delta * accel)
	if Input.is_action_pressed("view_zoomin") or Input.is_action_just_released("view_zoomin"):
		size -= 1
	elif Input.is_action_pressed("view_zoomout") or Input.is_action_just_released("view_zoomout"):
		size += 1
	if (size < 10): 
		size = 10
	elif (size > 60):
		size = 60
	if Input.is_action_just_released("view_rotate_left"):
		current_view += 1
		if (current_view > 3) : current_view = 0
		_rotate_view(current_view)
	elif Input.is_action_just_released("view_rotate_right"):
		current_view -= 1
		if (current_view < 0) : current_view = 3
		_rotate_view(current_view)

func _rotate_view(view:int):
	current_view = view
	position = positions[current_view]
	rotation_degrees = rotations[current_view]
	view_rotate.emit(current_view)
