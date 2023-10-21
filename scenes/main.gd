extends Node3D

@export var labelInfo:Label

func _ready():
	_on_change_zonelevel(GlobalState.game.zone_name, "default", false)
	if (GlobalState.game.position != Vector3.ZERO):
		_set_player_position(GlobalState.game.position, GlobalState.game.rotation)
	
func _set_player_position(pos:Vector3, rot:Vector3):
	$Game/Player.position = pos
	$Game/Player.rotation = rot
	$Game/CameraPivot/Camera.move(pos)

func _on_change_zonelevel(zone_name:String, spawnpoint_key:String, save:bool=true):
	GlobalState.game.zone_name = zone_name
	if (GlobalState.current_scene != null): 
		$Game/Player.disconnect("item_collected", GlobalState.current_scene.on_item_collected)
		$Game.remove_child(GlobalState.current_scene)
	GlobalState.current_scene = load("res://zones/" + zone_name + ".tscn").instantiate()
	GlobalState.current_scene.connect("change_zone", _on_change_zonelevel)
	$Game/Player.connect("item_collected", GlobalState.current_scene.on_item_collected)
	$Game.add_child(GlobalState.current_scene)
	for node in GlobalState.current_scene.get_children():
		if (node is SpawnPoint and node.key == spawnpoint_key):
			_set_player_position(node.position, node.rotation)
			break
	if (save): _save()

func _save():
	GlobalState.game.position = $Game/Player.position
	GlobalState.game.rotation = $Game/Player.rotation
	StateSaver.saveState(GlobalState.game)
	GlobalState.current_scene.save()

func _on_button_quit_pressed():
	_save()
	get_tree().quit()

func _on_button_inventory_pressed():
	_on_pause()
	var scene = load("res://scenes/inventory_screen.tscn").instantiate()
	add_child(scene)
	scene.connect("close", _on_resume)
	
func _on_pause():
	GlobalState.paused = true
	_save()
	$Game/UI.visible = false
	$Game.visible = false
	
func _on_resume(from:Node):
	remove_child(from)
	$Game/UI.visible = true
	$Game.visible = true
	GlobalState.paused = false

func _on_display_info(label:String):
	labelInfo.visible = true
	labelInfo.text = label

func _on_hide_info():
	labelInfo.visible = false
	labelInfo.text = ''

