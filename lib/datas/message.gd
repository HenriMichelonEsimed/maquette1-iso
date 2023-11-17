extends Node
class_name Message

var subject:String
var message:String
var read = false

func _init(_s, _m):
	subject = _s
	message = _m
