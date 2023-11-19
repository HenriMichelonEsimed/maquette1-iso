extends Node
class_name Message

var subject:String
var from:String
var message:String
var read = false

func _init(_f, _s, _m):
	from = _f
	subject = _s
	message = _m
