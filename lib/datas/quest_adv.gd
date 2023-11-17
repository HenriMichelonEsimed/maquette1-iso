extends Node
class_name QuestAdvancement

var label:String
var parent:QuestAdvancement
var nexts = []
var started = false

func _init(_label, _parent, _nexts):
	label = _label
	parent = _parent
	nexts = _nexts
	
func start():
	if (not started):
		_start()
		started = true
	
func _start():
	pass
	
func saveState(file:FileAccess):
	file.store_8(started if 1 else 0)

func loadState(file:FileAccess):
	started = file.get_8()
