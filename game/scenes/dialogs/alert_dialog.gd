extends Control

signal close(node:Node)

var _free_on_close:bool = true
var _just_opened = false

func _ready():
	visible = false
	
func _process(delta):
	if not visible: return
	if (_just_opened):
		_just_opened = false
		return
	if (Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("player_use_nomouse")):
		_on_button_cancel_pressed()
		
func open(title:String,message:String,free=true):
	_free_on_close = free
	$Panel/Content/VBoxContainer/Top/Label.text = tr(title)
	$Panel/Content/VBoxContainer/Label.text = tr(message)
	$Panel/Content/VBoxContainer/Bottom/ButtonCancel.grab_focus()
	visible = true
	_just_opened = true

func _on_button_cancel_pressed():
	close.emit(self)
	if _free_on_close: 
		queue_free()
	else:
		visible = false

