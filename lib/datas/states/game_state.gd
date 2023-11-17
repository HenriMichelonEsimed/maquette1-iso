extends Node

signal saving_start()
signal saving_end()

var paused:bool = false
var current_state_path = "autosave"
var current_zone:Zone
var main_quest = MainQuest.new()
var location = LocationState.new()
var camera = CameraState.new()
var inventory = ItemsCollection.new()
var events_queue = EventsQueue.new()
var messages = MessagesList.new()
var player:Player
var view_pivot:ViewPivot
var is_mobile:bool

func _ready():
	is_mobile = OS.get_name() in ["android", "iOS"]
	StateSaver.set_path(current_state_path)

func saveGame():
	saving_start.emit()
	location.position = player.position
	location.rotation = player.rotation
	StateSaver.saveState(MainQuestState.new(main_quest))
	StateSaver.saveState(MessagesState.new(messages))
	StateSaver.saveState(location)
	StateSaver.saveState(camera)
	StateSaver.saveState(InventoryState.new(inventory))
	StateSaver.saveState(EventsQueueState.new(events_queue))
	StateSaver.saveState(current_zone.state)
	saving_end.emit()

func loadGame():
	StateSaver.loadState(MainQuestState.new(main_quest))
	StateSaver.loadState(MessagesState.new(messages))
	StateSaver.loadState(location)
	StateSaver.loadState(camera)
	StateSaver.loadState(InventoryState.new(inventory))
	StateSaver.loadState(EventsQueueState.new(events_queue))

class MessagesState extends State:
	var messages:MessagesList
	func _init(_inv):
		super("messages")
		messages = _inv

class MainQuestState extends State:
	var main_quest:MainQuest
	func _init(_inv):
		super("main_quest")
		main_quest = _inv

class InventoryState extends State:
	var inventory:ItemsCollection
	func _init(_inv):
		super("inventory")
		inventory = _inv

class EventsQueueState extends State:
	var queue:EventsQueue
	func _init(_queue):
		super("events_queue")
		queue = _queue
