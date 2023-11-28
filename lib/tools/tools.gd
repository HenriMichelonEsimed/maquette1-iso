extends Object
class_name Tools

static func load_dialog(node:Node, dialog:String, close_func = null):
	var scene = load("res://scenes/" + dialog + ".tscn").instantiate()
	node.add_child(scene)
	if (close_func != null): scene.connect("close", close_func)
	return scene

static func show_item(item:Item, node_3d:Node3D):
	for c in node_3d.get_children():
		c.queue_free()
	var clone = item.duplicate()
	node_3d.add_child(clone)
	clone.position = Vector3.ZERO
	clone.rotation = Vector3.ZERO
	clone.scale = clone.scale * clone.preview_scale * 1.2
