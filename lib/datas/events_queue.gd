extends Node
class_name EventsQueue

var _queue = {}
	
func postEvent(zone:String,target:String,event:String):
	if (_qeue.has_node())
	_queue[zone] = []
