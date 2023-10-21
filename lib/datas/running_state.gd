extends Node
class_name RunningState

var paused:bool = false
var current_scene:Zone
var game = GameState.new()

func _ready():
	StateSaver.loadState(game)
