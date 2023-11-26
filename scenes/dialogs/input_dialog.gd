extends Control

signal input(text)

func _ready():
	visible = false
	
func _process(delta):
	if Input.is_action_just_pressed("cancel"):
		_on_button_cancel_pressed()
	elif Input.is_action_just_pressed("player_use_nomouse"):
		_on_button_ok_pressed()
		
func open(title:String,text:String):
	$Panel/Content/VBoxContainer/Edit.grab_focus()
	$Panel/Content/VBoxContainer/Top/Label.text = tr(title)
	$Panel/Content/VBoxContainer/Edit.text = tr(text)
	$Panel/Content/VBoxContainer/Edit.select_all()
	visible = true

func _on_button_cancel_pressed():
	input.emit(null)
	queue_free()

func _on_button_ok_pressed():
	input.emit($Panel/Content/VBoxContainer/Edit.text)
	queue_free()
