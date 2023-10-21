extends Node
class_name RunningState

var paused:bool = false
var current_scene:Zone
var location = LocationState.new()
var inventory = ItemsCollection.new()

func _ready():
	StateSaver.loadState(location)
