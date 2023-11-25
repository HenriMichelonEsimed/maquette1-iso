extends Node3D

@onready var camera = $Game/CameraPivot/Camera
@onready var labelInfo = $Game/UI/LabelInfo
@onready var notificationsList = $Game/UI/ListNotifications
@onready var notificationLabel = $Game/UI/LabelNotification
@onready var notificationTimer = $Game/UI/LabelNotification/Timer
@onready var optionMenu = $Game/UI/MarginContainer/VBoxContainer/OptionMenu
@onready var talkWindow = $TalkWindow
@onready var NPCPhraseLabel = $TalkWindow/MarginContainer/VBoxContainer/NPC
@onready var NPCNameLabel = $TalkWindow/MarginContainer/VBoxContainer/NPCName
@onready var playerTalkList = $TalkWindow/MarginContainer/VBoxContainer/Player
@onready var rayCast = $Game/CameraPivot/Camera/RayCast
@onready var optionMenuButtons = [
	$Game/UI/MarginContainer/VBoxContainer/OptionMenu/ButtonSave,
	$Game/UI/MarginContainer/VBoxContainer/OptionMenu/ButtonParams,
	$Game/UI/MarginContainer/VBoxContainer/OptionMenu/ButtonJoypad,
	$Game/UI/MarginContainer/VBoxContainer/OptionMenu/ButtonExit
]
var items_transfert_dialog:ItemsTransfertDialog
var last_spawnpoint:String
var talking_char:InteractiveCharacter
var _prev_lang:String
var _previous_zone:Zone
var talk_window_just_closed = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	_prev_lang = GameState.settings.lang
	if get_viewport().size.x > 1920:
		get_viewport().content_scale_factor = 2.2
	elif get_viewport().size.x >= 7680 :
		get_viewport().content_scale_factor = 3
	NotifManager.connect("new_notification", _on_new_notification)
	GameState.connect("saving_start", _on_saving_start)
	GameState.connect("saving_end", _on_saving_end)
	GameState.messages.connect("new_message", _on_new_message)
	GameState.player = $Game/Player
	GameState.view_pivot = $Game/ViewPivot
	TranslationServer.set_locale(GameState.settings.lang)
	camera.init()
	if (GameState.messages.have_unread()):
		_on_new_message()
	_change_zonelevel(GameState.location.zone_name, "default")
	if (GameState.location.position != Vector3.ZERO):
		_set_player_position(GameState.location.position, GameState.location.rotation)
	items_transfert_dialog = load("res://scenes/dialogs/items_transfert_dialog.tscn").instantiate()
	items_transfert_dialog.connect("close", _on_storage_close)
	GameState.quests.start("main")
	Input.connect("joy_connection_changed", _on_joypas_connection_changed)
	if (Input.get_connected_joypads().size() > 0):
		_on_joypas_connection_changed(null, true)
	#_on_button_inventory_pressed()
	#_on_button_terminal_pressed()
	#_on_button_load_pressed()
	
func _process(_delta):
	if (Input.is_action_just_pressed("exit_game")):
		get_tree().quit()
		return
	if (GameState.paused): 
		if (optionMenu.visible):
			if Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("player_optionsmenu") :
				optionMenu.visible = false
				_on_resume()
		elif (talkWindow.visible):
			if Input.is_action_just_pressed("player_use_nomouse") and playerTalkList.get_selected_items().size() > 0:
				_on_player_talk_item_clicked(playerTalkList.get_selected_items()[0], 0, 0)
		return
	if Input.is_action_pressed("player_moveto"):
		GameState.player.move_to(get_viewport().get_mouse_position(), camera)
	elif Input.is_action_just_released("player_moveto"):
		GameState.player.stop_move_to()
	elif Input.is_action_just_pressed("player_use_mouse") and not talk_window_just_closed:
		GameState.player.use(get_viewport().get_mouse_position(), camera)
	if Input.is_action_just_pressed("player_inventory"):
		_on_button_inventory_pressed()
	elif Input.is_action_just_pressed("player_terminal"):
		_on_button_terminal_pressed()
	elif Input.is_action_just_pressed("player_optionsmenu"):
		_on_button_optionsmenu_pressed()
	talk_window_just_closed = false

func _input(event):
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _set_player_position(pos:Vector3, rot:Vector3):
	GameState.player.position = pos
	GameState.player.rotation = rot
	camera.move(pos)
	GameState.view_pivot.position = pos
	GameState.view_pivot.position.y += 1.5
	
func _change_zonelevel(zone_name:String, spawnpoint_key:String):
	var new_zone:Zone
	if (_previous_zone != null) and (_previous_zone.zone_name == zone_name):
		new_zone = _previous_zone
	else:
		if (_previous_zone != null): 
			_previous_zone.queue_free()
		new_zone = GameState.getZone(zone_name).instantiate()
	if (GameState.current_zone != null): 
		GameState.player.disconnect("item_collected", GameState.current_zone.on_item_collected)
		GameState.current_zone.disconnect("change_zone", _on_change_zonelevel)
		for node in GameState.current_zone.find_children("*", "Storage", true, true):
			node.disconnect("open", _on_storage_open)
		for node in GameState.current_zone.find_children("*", "InteractiveCharacter", true, true):
			node.disconnect("talk", _on_npc_talk)
			node.disconnect("end_talk", _on_end_talk)
		$Game.remove_child(GameState.current_zone)
	_previous_zone = GameState.current_zone
	GameState.current_zone = new_zone
	GameState.location.zone_name = zone_name
	GameState.current_zone.connect("change_zone", _on_change_zonelevel)
	GameState.player.connect("item_collected", GameState.current_zone.on_item_collected)
	$Game.add_child(GameState.current_zone)
	_spawn_player(spawnpoint_key)
	for node in GameState.current_zone.find_children("*", "Storage", true, true):
		node.connect("open", _on_storage_open)
	for node in GameState.current_zone.find_children("*", "InteractiveCharacter", true, true):
		node.connect("trade", _on_npc_trade)
		node.connect("talk", _on_npc_talk)
		node.connect("end_talk", _on_end_talk)
		
func _on_change_zonelevel(trigger:ZoneChangeTrigger):
	if (trigger.zone_name == GameState.location.zone_name): 
		return
	GameState.saveGame()
	_change_zonelevel(trigger.zone_name, trigger.spawnpoint_key)
	trigger.is_triggered = false

func _on_player_reset_position():
	_spawn_player(last_spawnpoint)

func _spawn_player(spawnpoint_key:String):
	for node in GameState.current_zone.find_children("*", "SpawnPoint", false, true):
		if (node.key == spawnpoint_key):
			_set_player_position(node.global_position, node.global_rotation)
			node.spawn()
			break
	last_spawnpoint = spawnpoint_key

func _on_storage_open(node:Storage):
	_on_pause()
	add_child(items_transfert_dialog)
	items_transfert_dialog.open(node)
	
func _on_storage_close(node:Storage):
	remove_child(items_transfert_dialog)
	_on_resume()
	node.use()

func _on_new_message():
	_on_new_notification("You have unread messages !")

func _on_joypas_connection_changed(id,connected):
	GameState.use_joypad = connected
	if connected:
		if not GameState.settings.xbox_controller_shown:
			_on_button_joypad_pressed()
			GameState.settings.xbox_controller_shown = true
		$Game/UI/MarginContainer/VBoxContainer/OptionMenu/ButtonJoypad.icon_name = "gamepad"
		$Game/UI/MarginContainer/VBoxContainer/OptionMenu/ButtonJoypad.text = ""
	else:
		$Game/UI/MarginContainer/VBoxContainer/OptionMenu/ButtonJoypad.icon_name = "keyboard"
		$Game/UI/MarginContainer/VBoxContainer/OptionMenu/ButtonJoypad.text = ""


func _on_new_notification(message:String):
	notificationTimer.stop()
	var msg = tr(message)
	if (notificationsList.get_item_text(notificationsList.item_count - 1) != msg):
		notificationsList.add_item(msg)
	if (notificationsList.item_count > 5):
		notificationsList.remove_item(0)
	notificationLabel.text = msg
	notificationLabel.visible = true
	notificationTimer.start()

func _on_button_menu_pressed():
	optionMenu.visible = not optionMenu.visible
	
func _on_button_optionsmenu_pressed():
	_on_pause()
	optionMenuButtons[0].grab_focus()
	$Game/UI.visible = true
	optionMenu.visible = true

func _on_button_quit_pressed():
	var scene = load_dialog("dialogs/save_confirm_dialog")
	scene.connect("save_confirm", _on_save_confirm)
	
func _on_save_confirm(save:bool):
	if (save): GameState.saveGame(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().quit()

func _on_button_save_pressed():
	_on_pause()
	GameState.saveGame()
	_on_resume()
	optionMenu.visible = false

func load_dialog(filename:String):
	_on_pause()
	var scene = load("res://scenes/" + filename + ".tscn").instantiate()
	add_child(scene)
	scene.connect("close", _on_resume)
	return scene

func _on_button_inventory_pressed():
	load_dialog("inventory_screen")

func _on_button_terminal_pressed():
	load_dialog("terminal")

func _on_button_params_pressed():
	load_dialog("parameters_screen")

func _on_button_load_pressed():
	var scene = load_dialog("dialogs/load_savegame_dialog")
	scene.connect("load_savegame", _on_load_savegame)

func _on_button_joypad_pressed():
	_on_pause()
	var scene_name = "keyboard"
	if (GameState.use_joypad):
		scene_name = "xbox"
	var scene = load("res://scenes/controllers/" + scene_name + ".tscn").instantiate()
	add_child(scene)
	scene.connect("close", _on_resume)
	
func _on_load_savegame(savegame:String):
	GameState.loadGame(savegame)
	get_tree().reload_current_scene()
	_on_resume()

func _on_pause():
	GameState.paused = true
	$Game/UI.visible = false

func _on_resume(from:Node=null):
	if (from != null): remove_child(from)
	if (GameState.settings.lang != _prev_lang):
		_prev_lang = GameState.settings.lang
		notificationsList.clear() 
	if (not GameState.messages.have_unread()):
		for idx in range(0, notificationsList.item_count):
			if (notificationsList.get_item_text(idx) == tr("You have unread messages !")):
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

func _on_npc_trade(char:InteractiveCharacter):
	var scene = load("res://scenes/trade_screen.tscn").instantiate()
	add_child(scene)
	scene.connect("trade_end", _on_npc_trade_end)
	scene.open(char)
	
func _on_npc_trade_end(node:Node):
	node.queue_free()

func _on_npc_talk(char:InteractiveCharacter,phrase:String, answers:Array):
	_on_pause()
	talking_char = char
	NPCNameLabel.text = str(char)
	NPCPhraseLabel.text = tr(phrase)
	playerTalkList.clear()
	for i in range(0, answers.size()):
		var answer = answers[i]
		if (answer is Callable):
			answer = answer.call()
			if (answer == null): continue
		playerTalkList.add_item(tr(answer[0]))
		playerTalkList.set_item_metadata(playerTalkList.item_count-1, i)
	talkWindow.visible = true
	playerTalkList.grab_focus()
	if (playerTalkList.item_count > 0):
		playerTalkList.select(0)

func _on_end_talk():
	talk_window_just_closed = true
	talkWindow.visible = false
	_on_resume()

func _on_display_info(node:Node3D):
	var label = tr(str(node))
	if (label.is_empty()): return
	labelInfo.visible = true
	labelInfo.position =camera.unproject_position(node.global_position)
	labelInfo.text = label

func _on_hide_info():
	labelInfo.visible = false
	labelInfo.text = ''

func _on_notification_timer_timeout():
	notificationLabel.visible = false

func _on_player_talk_item_clicked(index, at_position, mouse_button_index):
	talking_char.answer(playerTalkList.get_item_metadata(index))

