extends Control

signal close(node:Node)

@onready var listMessages = $Screen/Content/Control/ListMessages
@onready var labelMessage = $Screen/Content/Control/LabelMessage
@onready var listQuests = $Screen/Content/Control/ListQuests

func _ready():
	_update()
	
func _update():
	listMessages.clear()
	for message in GameState.messages.messages:
		listMessages.add_item(message.subject)
		if (not message.read):
			listMessages.set_item_custom_fg_color (listMessages.item_count-1, Color.YELLOW)
	listQuests.clear()
	listQuests.append_text("[b]" + GameState.main_quest.label + "[/b]\n")
	listQuests.append_text(GameState.main_quest.current.label)

func _on_button_back_pressed():
	close.emit(self)
	queue_free()
	
func _hide_all():
	listMessages.visible = false
	labelMessage.visible = false
	listQuests.visible = false

func _on_button_list_messages_pressed():
	_hide_all()
	listMessages.visible = true

func _on_button_home_term_pressed():
	_hide_all()

func _on_list_messages_item_clicked(index, _at_position, _mouse_button_index):
	_hide_all()
	var message = GameState.messages.messages[index]
	message.read = true
	labelMessage.clear()
	labelMessage.append_text("From : [b]" + message.from + "[/b]\n")
	labelMessage.append_text("Subject: [b]" + message.subject + "[/b]\n")
	labelMessage.append_text(message.message)
	message.read = true
	labelMessage.visible = true
	QuestsEvents.event(QuestEvents.QuestEventType.QUESTEVENT_READMESSAGE, message.key)
	_update()

func _on_button_quests_pressed():
	_hide_all()
	listQuests.visible = true
