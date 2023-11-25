extends Control

signal close(node:Node)

func _ready():
	visible = false
	$Panel/Content/VBoxContainer/Bottom/ButtonCancel.grab_focus()
	
func _process(delta):
	if (Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("player_use_nomouse")):
		_on_button_cancel_pressed()
		
func open(title:String,message:String,button:String="Ok"):
	$Panel/Content/VBoxContainer/Top/Label.text = tr(title)
	$Panel/Content/VBoxContainer/Label.text = tr(message)
	$Panel/Content/VBoxContainer/Bottom/ButtonCancel.text = str(button)
	visible = true

func _on_button_cancel_pressed():
	visible = false
	close.emit(self)

