extends Control

signal close(node:Node)

func _ready():
	for message in GameState.messages.messages:
		$Screen/Content/Control/ListMessages.add_item(message.subject)

func _on_button_back_pressed():
	close.emit(self)
	queue_free()

func _on_button_list_messages_pressed():
	$Screen/Content/Control/ListMessages.visible = true
	$Screen/Content/Control/LabelMessage.visible = false


func _on_button_home_term_pressed():
	$Screen/Content/Control/ListMessages.visible = false
	$Screen/Content/Control/LabelMessage.visible = false

func _on_list_messages_item_clicked(index, at_position, mouse_button_index):
	var message = GameState.messages.messages[index]
	$Screen/Content/Control/LabelMessage.clear()
	$Screen/Content/Control/LabelMessage.append_text("[b]" + message.subject + "[/b]\n")
	$Screen/Content/Control/LabelMessage.append_text(message.message)
	$Screen/Content/Control/ListMessages.visible = false
	$Screen/Content/Control/LabelMessage.visible = true
