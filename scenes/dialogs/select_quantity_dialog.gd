extends Control

signal quantity(quantity:int)

@onready var sliderQuantity = $Content/Body/SliderQuantity
@onready var labelQuantity = $Content/Body/LabelQuantity
@onready var labelName = $Content/Body/Top/LabelName
@onready var buttonDrop =$Content/Body/Buttons/ButtonDrop

var _slide_pressed = 0
var _just_opened = true
var func_quantity:Callable

func _process(_delta):
	if not visible: return
	if (_just_opened):
		_just_opened = false
		return
	if Input.is_action_just_pressed("cancel"):
		_on_button_cancel_pressed()
		return
	elif Input.is_action_just_pressed("player_use_nomouse"):
		_on_button_drop_pressed()
		return
	if sliderQuantity.has_focus():
		if (_slide_pressed > 10):
			if Input.is_action_pressed("shortcut_left"):
				sliderQuantity.value -= 2
			elif Input.is_action_pressed("shortcut_right"):
				sliderQuantity.value += 2
		else :
			if Input.is_action_pressed("shortcut_left") or Input.is_action_pressed("shortcut_right"):
				_slide_pressed += 1
		if Input.is_action_just_released("shortcut_left"):
			sliderQuantity.value -= 1
			_slide_pressed = 0
		elif Input.is_action_just_released("shortcut_right"):
			sliderQuantity.value += 1
			_slide_pressed = 0

func open(item:Item, all:bool, label:String="Transfert", func_qty=_quantity):
	_just_opened = true
	buttonDrop.text = tr(label)
	labelName.text = tr(item.label)
	func_quantity = func_qty
	sliderQuantity.max_value = item.quantity
	sliderQuantity.value = item.quantity if all else 1
	labelQuantity.text = func_quantity.call(sliderQuantity.value)
	sliderQuantity.grab_focus()
	visible = true
	
func _quantity(value):
	return str(value)

func _on_slider_quantity_value_changed(value):
	labelQuantity.text = func_quantity.call(value)

func _on_button_cancel_pressed():
	visible = false

func _on_button_drop_pressed():
	visible = false
	quantity.emit(sliderQuantity.value)

