extends Object
class_name TalkAnswer

var answer:String
var action:Callable

func _init(_an, _ac):
	answer = _an
	action = _ac
