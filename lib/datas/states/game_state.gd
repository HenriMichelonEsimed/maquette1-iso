extends Node

signal saving_start()
signal saving_end()

var paused:bool = false
var current_state_path = "autosave"
var current_zone:Zone
var location = LocationState.new()
var camera = CameraState.new()
var inventory = ItemsCollection.new()
var events_queue = EventsQueue.new()
var player:Player

func _ready():
	StateSaver.set_path(current_state_path)
	loadGame()

func saveGame():
	saving_start.emit()
	location.position = player.position
	location.rotation = player.rotation
	StateSaver.saveState(location)
	StateSaver.saveState(camera)
	StateSaver.saveState(InventoryState.new(inventory))
	StateSaver.saveState(current_zone.state)
	saving_end.emit()
	
func loadGame():
	StateSaver.loadState(location)
	StateSaver.loadState(camera)
	StateSaver.loadState(InventoryState.new(inventory))

	
class InventoryState extends State:
	var inventory:ItemsCollection
	func _init(_inv):
		super("inventory")
		inventory = _inv
