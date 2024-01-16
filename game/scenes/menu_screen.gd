extends Control

@onready var background:TextureRect = $TextureRect
@onready var button_continue:Button = $TextureRect/VBoxContainer/ButtonContinue
@onready var button_new:Button = $TextureRect/VBoxContainer/ButtonNewGame

func _ready():
	button_continue.disabled = StateSaver.get_savegames().is_empty()
	if (button_continue.disabled):
		button_new.grab_focus()

func _physics_process(delta):
	var texture:NoiseTexture2D = background.texture
	var noise:FastNoiseLite = texture.noise
	noise.seed = randi()

func _on_button_continue_pressed():
	if (button_continue.disabled) : return
	GameState.loadGame(StateSaver.get_last())
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_button_quit_pressed():
	get_tree().quit()

func _on_button_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
