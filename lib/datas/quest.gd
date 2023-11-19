extends Node
class_name Quest

var key:String
var label:String
var starting_point:QuestAdvancement
var current:QuestAdvancement

func _init(_k, _start, _label):
	key = _k
	label = _label
	starting_point = _start
	current = starting_point
	
func start():
	current.start()
	
func on_new_quest_event(type:QuestEvents.QuestEventType, event_key:String):
	current.on_new_quest_event(type, event_key)
	var next = current.success()
	if (next != null):
		current.terminated = true
		var current_class = load_adv(next)
		## nil GAME ERROR
		current = current_class.new()
		current.start()
		
func load_adv(adv:String):
	return load("res://lib/quests/" + key + "/" + adv + ".gd")

func saveState(file:FileAccess):
	var classname = current.key
	file.store_pascal_string(classname)
	current.saveState(file)

func loadState(file:FileAccess):
	var classname = file.get_pascal_string()
	var current_class = load_adv(classname)
	## nil GAME ERROR
	current = current_class.new()
	## nil else GAME ERROR
	current.loadState(file)
