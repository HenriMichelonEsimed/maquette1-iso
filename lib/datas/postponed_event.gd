extends Node
class_name PostponedEvent

var target:String
var event:String

func _init(_target, _event):
	target = _target
	event = _event
