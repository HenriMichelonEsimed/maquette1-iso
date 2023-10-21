extends Node3D

@export var labelInfo:Label

var current_scene:Zone
var state = MainState.new()

func _ready():
	StateSaver.loadState(state)
	_on_change_zonelevel(state.zone_name, "default", false)
	if (state.position != Vector3.ZERO):
		_set_player_position(state.position, state.rotation)
	
func _set_player_position(pos:Vector3, rot:Vector3):
	$Game/Player.position = pos
	$Game/Player.rotation = rot
	$Game/CameraPivot/Camera.move(pos)

func _on_change_zonelevel(zone_name:String, spawnpoint_key:String, save:bool=true):
	state.zone_name = zone_name
	if (current_scene != null): 
		$Player.disconnect("item_collected", current_scene.on_item_collected)
		$Game.remove_child(current_scene)
	current_scene = load("res://zones/" + zone_name + ".tscn").instantiate()
	current_scene.connect("change_zone", _on_change_zonelevel)
	$Game/Player.connect("item_collected", current_scene.on_item_collected)
	$Game.add_child(current_scene)
	for node in current_scene.get_children():
		if (node is SpawnPoint and node.key == spawnpoint_key):
			_set_player_position(node.position, node.rotation)
			break
	if (save): _save()

func _save():
	state.position = $Game/Player.position
	state.rotation = $Game/Player.rotation
	StateSaver.saveState(state)
	current_scene.save()

func _on_button_quit_pressed():
	_save()
	get_tree().quit()

func _on_button_inventory_pressed():
	_on_pause()
	var scene = load("res://scenes/inventory_screen.tscn").instantiate()
	add_child(scene)
	scene.connect("close", _on_resume)
	
func _on_pause():
	GameState.paused = true
	_save()
	$Game/UI.visible = false
	$Game.visible = false
	
func _on_resume(from:Node):
	remove_child(from)
	$Game/UI.visible = true
	$Game.visible = true
	GameState.paused = false

func _on_display_info(label:String):
	labelInfo.visible = true
	labelInfo.text = label

func _on_hide_info():
	labelInfo.visible = false
	labelInfo.text = ''

class MainState extends State:
	var zone_name:String = "PM/pm_1"
	var position:Vector3 = Vector3.ZERO
	var rotation:Vector3 = Vector3.ZERO
	func _init():
		super("main")
