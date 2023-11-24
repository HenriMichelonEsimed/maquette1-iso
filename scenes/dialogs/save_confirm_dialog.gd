extends Control

signal save_confirm(save_confirm:bool)

func _ready():
	$Panel/Content/VBoxContainer/Bottom/ButtonSave.grab_focus()
	
func _process(delta):
	if (Input.is_action_just_pressed("cancel")):
		_on_button_cancel_pressed()
	elif Input.is_action_just_pressed("player_use_nomouse"):
		_on_button_save_pressed()

func _on_button_save_pressed():
	save_confirm.emit(true)

func _on_button_cancel_pressed():
	save_confirm.emit(false)
