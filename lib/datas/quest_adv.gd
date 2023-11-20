extends Node
class_name QuestAdvancement

var key:String
var label:String
var parent:String
var started = false
var terminated = false

func _init(_k, _parent, _label):
	key = _k
	label = _label
	parent = _parent

func start():
	if (not started):
		_start()
		started = true
	NotifManager.notif(label)

func _start():
	pass

func on_new_quest_event(type:Quest.QuestEventType, key:String):
	pass

func success():
	return null
	
func saveState(file:FileAccess):
	file.store_8(started if 1 else 0)

func loadState(file:FileAccess):
	started = file.get_8() == 1
