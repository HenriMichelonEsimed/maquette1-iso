extends Node
class_name Quest

var label:String
var starting_point:QuestAdvancement
var current:QuestAdvancement

func _init(_label, _start):
	label = _label
	starting_point = _start
	current = starting_point
	
func start():
	current.start()

func saveState(file:FileAccess):
	var classname = current.label
	file.store_pascal_string(classname)
	current.saveState(file)

func loadState(file:FileAccess):
	var classname = file.get_pascal_string()
	var current_class = load("res://lib/quests/" + label + "/" + classname + ".gd")
	if (current_class != null):
		current = current_class.new()
	## XXX else STOP GAME
	current.loadState(file)
