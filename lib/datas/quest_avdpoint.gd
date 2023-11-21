extends Node
class_name QuestAdvancementPoint

var key:String
var label:String
var finished = false

func _init(_k = "", _label = ""):
	key = _k
	label = _label

func saveState(file:FileAccess):
	file.store_pascal_string(key)
	file.store_8(finished if 1 else 0)

func loadState(file:FileAccess):
	key = file.get_pascal_string()
	finished = file.get_8() == 1
