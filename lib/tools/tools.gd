extends Object
class_name Tools

static func load_dialog(node:Node, dialog:String, close_func = null):
	var scene = load("res://scenes/" + dialog + ".tscn").instantiate()
	node.add_child(scene)
	if (close_func != null): scene.connect("close", close_func)
	return scene
