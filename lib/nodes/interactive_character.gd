extends CharacterBody3D
class_name InteractiveCharacter

@export var label:String
signal talk(char:InteractiveCharacter,phrase:String, answers:Array)
signal end_talk()

var level = 0

func _ready():
	set_collision_layer_value(5, true)
	
func interact():
	say(0, "Hello.", ["Bye."])
	
func say(_l:int, phrase:String, answers:Array):
	level = _l
	talk.emit(self, phrase, answers)
	
func end():
	end_talk.emit()
	
func answer(index:int):
	end()

func _to_string():
	return label
