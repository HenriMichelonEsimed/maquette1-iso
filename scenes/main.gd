extends Node3D

@export var labelInfo:Label

func _ready():
	GameState.connect("saving_start", _on_saving_start)
	GameState.connect("saving_end", _on_saving_end)
	GameState.player = $Game/Player
	_on_change_zonelevel(GameState.location.zone_name, "default", false)
	if (GameState.location.position != Vector3.ZERO):
		_set_player_position(GameState.location.position, GameState.location.rotation)
	_on_button_inventory_pressed()
	
func _process(delta):
	if (GameState.paused): return
	if Input.is_action_just_pressed("player_inventory"):
		_on_button_inventory_pressed()
	
func _set_player_position(pos:Vector3, rot:Vector3):
	GameState.player.position = pos
	GameState.player.rotation = rot
	$Game/CameraPivot/Camera.move(pos)

func _on_change_zonelevel(zone_name:String, spawnpoint_key:String, save:bool=true):
	if (save): GameState.saveGame()
	GameState.location.zone_name = zone_name
	if (GameState.current_scene != null): 
		GameState.player.disconnect("item_collected", GameState.current_scene.on_item_collected)
		GameState.current_scene.queue_free()
	GameState.current_scene = load("res://zones/" + zone_name + ".tscn").instantiate()
	GameState.current_scene.connect("change_zone", _on_change_zonelevel)
	GameState.player.connect("item_collected", GameState.current_scene.on_item_collected)
	$Game.add_child(GameState.current_scene)
	for node in GameState.current_scene.get_children():
		if (node is SpawnPoint and node.key == spawnpoint_key):
			_set_player_position(node.position, node.rotation)
			break

func _on_button_quit_pressed():
	GameState.saveGame()
	get_tree().quit()

func _on_button_inventory_pressed():
	_on_pause()
	var scene = load("res://scenes/inventory_screen.tscn").instantiate()
	add_child(scene)
	scene.connect("close", _on_resume)
	
func _on_pause():
	GameState.paused = true
	$Game/UI.visible = false
	$Game.visible = false
	
func _on_resume(from:Node):
	remove_child(from)
	$Game/UI.visible = true
	$Game.visible = true
	GameState.paused = false
	
func _on_saving_start():
	$Game/UI/LabelSaving.visible = true

func _on_saving_end():
	$Game/UI/LabelSaving/Timer.start()
	
func _on_saving_timer_timeout():
	$Game/UI/LabelSaving.visible = false

func _on_display_info(label:String):
	labelInfo.visible = true
	labelInfo.text = label

func _on_hide_info():
	labelInfo.visible = false
	labelInfo.text = ''

