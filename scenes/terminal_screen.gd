extends Control

signal close(node:Node)

@onready var listMessages = $Content/Content/Body/ListMessages
@onready var labelMessage = $Content/Content/Body/LabelMessage
@onready var listQuests = $Content/Content/Body/ListQuests
@onready var labelCurrent = $Content/Content/Label
@onready var buttonQuests = $Content/HBoxContainer/ButtonQuests
@onready var buttonMessages = $Content/HBoxContainer/ButtonMessages
var currentButton:Button
var displayMessage = false

func _ready():
	_update()
	_on_button_quests_pressed()
	
func _process(_delta):
	if Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("player_terminal"):
		if (displayMessage):
			_on_button_list_messages_pressed()
		else:
			_on_button_back_pressed()
			return
	if Input.is_action_just_pressed("shortcut_left") or Input.is_action_just_pressed("shortcut_right"):
		if (currentButton == buttonQuests):
			_on_button_list_messages_pressed()
		else:
			_on_button_quests_pressed()
	if (currentButton == buttonMessages):
		if Input.is_action_just_pressed("player_use") and listMessages.has_focus() and listMessages.get_selected_items().size() > 0 :
			_on_list_messages_item_clicked(listMessages.get_selected_items()[0], 0, 0)

func _update():
	listMessages.clear()
	for message in GameState.messages.messages:
		listMessages.add_item(message.subject)
		if (not message.read):
			listMessages.set_item_custom_fg_color (listMessages.item_count-1, Color.YELLOW)
	listQuests.clear()
	listQuests.append_text("[b]" + GameState.quests.label("main") + "[/b]\n")
	listQuests.append_text(GameState.quests.current("main").label + "\n")
	for adv in GameState.quests.get_advpoints("main"):
		listQuests.append_text("\t[i]" + adv.label + "[/i]\n")

func _on_button_back_pressed():
	close.emit(self)
	
func _hide_all():
	listMessages.visible = false
	labelMessage.visible = false
	listQuests.visible = false
	labelCurrent.visible = false
	displayMessage = false

func _on_button_list_messages_pressed():
	_hide_all()
	labelCurrent.text = "Messages"
	currentButton = buttonMessages
	listMessages.grab_focus()
	listMessages.visible = true
	labelCurrent.visible = true

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
	GameState.quests.event_all(Quest.QuestEventType.QUESTEVENT_READMESSAGE, message.key)
	_update()
	displayMessage = true

func _on_button_quests_pressed():
	_hide_all()
	labelCurrent.text = "Quests"
	currentButton = buttonQuests
	listQuests.visible = true
	labelCurrent.visible = true
