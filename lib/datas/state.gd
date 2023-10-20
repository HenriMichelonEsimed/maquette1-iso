extends Object
class_name State

var name:String
var parent:Node

func _init(_name:String, _parent:Node=null):
	self.parent = _parent
	self.name = _name
