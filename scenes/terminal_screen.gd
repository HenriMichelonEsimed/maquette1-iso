extends Control

signal close(node:Node)

func _on_button_back_pressed():
	close.emit(self)
	queue_free()

func _on_button_list_messages_pressed():
	$Screen/Content/Control/ListMessages.visible = true


func _on_button_home_term_pressed():
	$Screen/Content/Control/ListMessages.visible = false
