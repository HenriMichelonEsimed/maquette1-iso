extends Control

signal close(node:Node)

func _on_button_back_pressed():
	close.emit(self)
	queue_free()

func _on_button_list_messages_pressed():
	$Screen/Content/Control/ListMessages.visible = true
	$Screen/Content/Control/LabelMessage.visible = false


func _on_button_home_term_pressed():
	$Screen/Content/Control/ListMessages.visible = false
	$Screen/Content/Control/LabelMessage.visible = false


func _on_list_messages_item_selected(index):
	$Screen/Content/Control/ListMessages.visible = false
	$Screen/Content/Control/LabelMessage.visible = true
