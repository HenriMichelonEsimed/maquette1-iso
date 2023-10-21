extends Node
class_name RunningState

var paused:bool = false
var player_inventory:ItemsCollection

func _ready():
	player_inventory = ItemsCollection.new()
