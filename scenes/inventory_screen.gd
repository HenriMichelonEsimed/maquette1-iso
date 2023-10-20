extends Control

signal close(node:Node)

func _on_button_back_pressed():
	close.emit(self)

func _process(_delta):
	if (Input.is_action_just_pressed("cancel")):_on_button_back_pressed()
