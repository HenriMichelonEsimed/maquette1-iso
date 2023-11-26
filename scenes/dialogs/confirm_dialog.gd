extends Control

signal confirm(confirm:bool)
signal close(node:Node)

func _ready():
	visible = false
	
func _process(delta):
	if not visible: return
	if (Input.is_action_just_pressed("cancel")):
		_on_button_cancel_pressed()
	elif Input.is_action_just_pressed("player_use_nomouse"):
		_on_button_yes_pressed()

func open(title:String,text:String):
	$Panel/Content/VBoxContainer/Top/Label.text = tr(title)
	$Panel/Content/VBoxContainer/Label.text = tr(text)
	$Panel/Content/VBoxContainer/Bottom/ButtonYes.grab_focus()
	visible = true

func _on_button_yes_pressed():
	confirm.emit(true)
	queue_free()

func _on_button_cancel_pressed():
	close.emit(self)
	queue_free()

func _on_button_no_pressed():
	confirm.emit(false)
	queue_free()

