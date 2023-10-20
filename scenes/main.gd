extends Node3D

var current_scene:Zone
var state = MainState.new()

func _ready():
	StateSaver.loadState(state)
	_on_change_zonelevel(state.current_zone_name, "default", false)
	if (state.current_position != Vector3.ZERO):
		_set_player_position(state.current_position, state.current_rotation)
	PlayerInventory.add($Tool1)
	PlayerInventory.add($UniqueTool1)
	PlayerInventory.add($Tool1)
	PlayerInventory.add($UniqueTool1)
	
func _set_player_position(pos:Vector3, rot:Vector3):
	$Player.position = pos
	$Player.rotation = rot
	$CameraPivot/Camera.move(pos)

func _on_change_zonelevel(zone_name:String, spawnpoint_key:String, save:bool=true):
	state.current_zone_name = zone_name
	if (current_scene != null): remove_child(current_scene)
	current_scene = load("res://zones/" + zone_name + ".tscn").instantiate()
	current_scene.connect("change_zone", _on_change_zonelevel)
	add_child(current_scene)
	for node in current_scene.get_children():
		if (node is SpawnPoint and node.key == spawnpoint_key):
			_set_player_position(node.position, node.rotation)
			break
	if (save): _save()
	
func _on_button_quit_pressed():
	_save()
	get_tree().quit()

func _save():
	state.current_position = $Player.position
	state.current_rotation = $Player.rotation
	StateSaver.saveState(state)
	current_scene.save()

class MainState extends State:
	var current_zone_name:String = "PM/pm_1"
	var current_position:Vector3 = Vector3.ZERO
	var current_rotation:Vector3 = Vector3.ZERO
	func _init():
		super("main")
