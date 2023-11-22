extends CharacterBody3D
class_name InteractiveCharacter

@export var label:String
signal talk(char:InteractiveCharacter,phrase:String, answers:Array)
signal end_talk()

var discussion:Array
var current:Array

func _init(disc = ["Hello !", [["Bye.", end]] ]):
	discussion = disc

func _ready():
	set_collision_layer_value(5, true)
	
func interact():
	say(discussion)
	
func say(disc):
	current = disc
	var phrase = current[0]
	var answr = current[1]
	if phrase is Array:
		var fun = phrase[1]
		if (phrase.size() == 3):
			var param = phrase[2]
			fun.call(param)
		else:
			fun.call()
		phrase = phrase[0]
	talk.emit(self, phrase, answr)
	
func end():
	end_talk.emit()
	
func answer(index:int):
	var next = current[1][index]
	if (next is Callable):
		next = next.call()
	next = next[1]
	if (next is Callable):
		next = next.call()
	if next is Array:
		say(next)

func _to_string():
	return label
