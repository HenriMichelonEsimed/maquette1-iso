extends Node3D

@onready var labelInfo = $Game/UI/LabelInfo
@onready var notificationsList = $Game/UI/ListNotifications
@onready var notificationLabel = $Game/UI/LabelNotification
@onready var notificationTimer = $Game/UI/LabelNotification/Timer
@onready var talkWindow = $Game/TalkWindow
@onready var NPCPhraseLabel = $Game/TalkWindow/VBoxContainer/NPC
@onready var playerTalkList = $Game/TalkWindow/VBoxContainer/Player
var items_transfert_dialog:ItemsTransfertDialog
var last_spawnpoint:String
var talking_char:InteractiveCharacter

func _ready():
	NotifManager.connect("new_notification", _on_new_notification)
	GameState.connect("saving_start", _on_saving_start)
	GameState.connect("saving_end", _on_saving_end)
	GameState.messages.connect("new_message", _on_new_message)
	GameState.player = $Game/Player
	GameState.view_pivot = $Game/ViewPivot
	GameState.loadGame()
	$Game/CameraPivot/Camera.init()
	if (GameState.messages.have_unread()):
		_on_new_message()
	_on_change_zonelevel(GameState.location.zone_name, "default", false)
	if (GameState.location.position != Vector3.ZERO):
		_set_player_position(GameState.location.position, GameState.location.rotation)
	items_transfert_dialog = load("res://scenes/dialogs/items_transfert_dialog.tscn").instantiate()
	items_transfert_dialog.connect("close", _on_storage_close)
	QuestsEvents.connect("questevent", _on_new_quest_event)
	GameState.main_quest.start()
	#_on_button_inventory_pressed()
	_on_button_terminal_pressed()
	
func _process(_delta):
	if (GameState.paused): return
	if Input.is_action_just_pressed("player_inventory"):
		_on_button_inventory_pressed()
	elif Input.is_action_just_pressed("player_terminal"):
		_on_button_terminal_pressed()

func _input(event):
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _set_player_position(pos:Vector3, rot:Vector3):
	GameState.player.position = pos
	GameState.player.rotation = rot
	$Game/CameraPivot/Camera.move(pos)
	GameState.view_pivot.position = pos
	GameState.view_pivot.position.y += 1.5

func _on_change_zonelevel(zone_name:String, spawnpoint_key:String, save:bool=true):
	if (save): GameState.saveGame()
	GameState.location.zone_name = zone_name
	if (GameState.current_zone != null): 
		GameState.player.disconnect("item_collected", GameState.current_zone.on_item_collected)
		GameState.current_zone.queue_free()
	GameState.current_zone = load("res://zones/" + zone_name + ".tscn").instantiate()
	GameState.current_zone.connect("change_zone", _on_change_zonelevel)
	GameState.player.connect("item_collected", GameState.current_zone.on_item_collected)
	$Game.add_child(GameState.current_zone)
	_spawn_player(spawnpoint_key)
	for node in GameState.current_zone.find_children("*", "Storage", true, true):
		node.connect("open", _on_storage_open)
	for node in GameState.current_zone.find_children("*", "InteractiveCharacter", true, true):
		node.connect("talk", _on_npc_talk)
		node.connect("end_talk", _on_end_talk)
func _on_new_quest_event(type:QuestEvents.QuestEventType, event_key:String):
	GameState.main_quest.on_new_quest_event(type, event_key)
	GameState.current_zone.check_quest_advance()
	
func _on_player_reset_position():
	_spawn_player(last_spawnpoint)

func _spawn_player(spawnpoint_key:String):
	for node in GameState.current_zone.find_children("*", "SpawnPoint", false, true):
		if (node.key == spawnpoint_key):
			_set_player_position(node.position, node.rotation)
			break
	last_spawnpoint = spawnpoint_key

func _on_storage_open(node:Storage):
	_on_pause(false)
	add_child(items_transfert_dialog)
	items_transfert_dialog.open(node)
	
func _on_storage_close(node:Storage):
	remove_child(items_transfert_dialog)
	_on_resume()
	node.use()

func _on_new_message():
	notificationsList.add_item("You have unread messages !")

func _on_new_notification(message:String):
	if (notificationsList.get_item_text(notificationsList.item_count - 1) != message):
		notificationsList.add_item(message)
	notificationLabel.text = message
	notificationLabel.visible = true
	notificationTimer.start()

func _on_button_quit_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameState.saveGame()
	get_tree().quit()

func _on_button_inventory_pressed():
	_on_pause()
	var scene = load("res://scenes/inventory_screen.tscn").instantiate()
	add_child(scene)
	scene.connect("close", _on_resume)

func _on_button_terminal_pressed():
	_on_pause()
	var scene = load("res://scenes/terminal_screen.tscn").instantiate()
	add_child(scene)
	scene.connect("close", _on_resume)
	
func _on_pause(hidegame:bool=true):
	GameState.paused = true
	$Game/UI.visible = false
	$Game.visible = !hidegame
	
func _on_resume(from:Node=null):
	if (from != null): remove_child(from)
	if (not GameState.messages.have_unread()):
		for idx in range(0, notificationsList.item_count):
			if (notificationsList.get_item_text(idx) == "You have unread messages !"):
				notificationsList.remove_item(idx)
	$Game/UI.visible = true
	$Game.visible = true
	GameState.player.just_resumed = true
	GameState.paused = false
	
func _on_saving_start():
	$Game/UI/LabelSaving.visible = true

func _on_saving_end():
	$Game/UI/LabelSaving/Timer.start()
	
func _on_saving_timer_timeout():
	$Game/UI/LabelSaving.visible = false

func _on_npc_talk(char:InteractiveCharacter,phrase:String, answers:Array):
	_on_pause(false)
	talking_char = char
	NPCPhraseLabel.text = phrase
	playerTalkList.clear()
	for answer in answers:
		playerTalkList.add_item(answer)
	talkWindow.visible = true

func _on_end_talk():
	talkWindow.visible = false
	_on_resume()

func _on_display_info(node:Node3D):
	var label = str(node)
	if (label.is_empty()): return
	labelInfo.visible = true
	labelInfo.position = $Game/CameraPivot/Camera.unproject_position(node.global_position)
	labelInfo.text = label

func _on_hide_info():
	labelInfo.visible = false
	labelInfo.text = ''

func _on_notification_timer_timeout():
	notificationLabel.visible = false

func _on_player_talk_item_clicked(index, at_position, mouse_button_index):
	talking_char.answer(index)
