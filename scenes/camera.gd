extends Camera3D

@export var cameraPivotPath: NodePath
@export var objectToFollowPath: NodePath
@onready var cameraPivot = get_node(cameraPivotPath)
@onready var objectToFollow = get_node(objectToFollowPath)

@export var camAccel = 2

func move(pos):
	cameraPivot.position = pos

func _process(delta):
	cameraPivot.position = cameraPivot.position.lerp(objectToFollow.position, delta * camAccel)
