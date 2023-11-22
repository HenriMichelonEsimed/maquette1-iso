extends Control

signal close(node:Node)

@onready var listMessages = $Borders/Screen/Content/Content/Body/MarginContainer/ListMessages
@onready var labelMessage = $Borders/Screen/Content/Content/Body/MarginContainer/LabelMessage
@onready var listQuests = $Borders/Screen/Content/Content/Body/MarginContainer/ListQuests
@onready var labelCurrent = $Borders/Screen/Content/Content/Label
@onready var buttonQuests = $Borders/Screen/Content/HBoxContainer/ButtonQuests
@onready var buttonMessages = $Borders/Screen/Content/HBoxContainer/ButtonMessages
var currentButton:Button
var displayMessage = false

func _ready():
	var ratio = size.y / size.x
	var vsize = get_viewport().size / get_viewport().content_scale_factor
	size.y = vsize.y - 20
	size.x = size.y / ratio
	position.x = (vsize.x - size.x) / 2
	position.y = (vsize.y - size.y) / 2
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
		listMessages.add_item(tr(message.subject))
		if (not message.read):
			listMessages.set_item_custom_fg_color (listMessages.item_count-1, Color.YELLOW)
	listQuests.clear()
	listQuests.append_text("[color=yellow]" + tr(GameState.quests.label("main")) + "[/color]\n")
	listQuests.append_text(tr(GameState.quests.current("main").label) + "\n")
	for adv in GameState.quests.get_advpoints("main"):
		listQuests.append_text("\t[i]" + tr(adv.label) + "[/i]\n")

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
	labelCurrent.text = tr("Messages")
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
	labelCurrent.text = tr("Message")
	labelCurrent.visible = true
	labelMessage.clear()
	labelMessage.append_text(tr("From"))
	labelMessage.append_text(": [color=yellow]" + tr(message.from) + "[/color]\n")
	labelMessage.append_text(tr("Subject"))
	labelMessage.append_text(": [color=yellow]" + tr(message.subject) + "[/color]\n")
	print(message.message)
	print(tr(message.message))
	labelMessage.append_text(tr(message.message))
	message.read = true
	labelMessage.visible = true
	GameState.quests.event_all(Quest.QuestEventType.QUESTEVENT_READMESSAGE, message.key)
	_update()
	displayMessage = true

func _on_button_quests_pressed():
	_hide_all()
	labelCurrent.text = tr("Quests")
	currentButton = buttonQuests
	listQuests.visible = true
	labelCurrent.visible = true
