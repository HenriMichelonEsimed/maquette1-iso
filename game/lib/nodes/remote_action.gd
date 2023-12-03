extends Usable
class_name RemoteAction

@export var remote_node:RemoteUsable

func _init():
	super(false)

func _use():
	if (remote_node != null): remote_node.use()

func _unuse():
	if (remote_node != null): remote_node.use()
