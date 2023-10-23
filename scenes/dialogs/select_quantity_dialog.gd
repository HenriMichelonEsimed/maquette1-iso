extends Control

signal quantity(quantity:int)
var _slide_pressed = 0
var _just_opened = true

func _process(_delta):
	if (visible):
		if Input.is_action_just_pressed("player_use"):
			if (_just_opened):
				_just_opened = false
			else:
				_on_button_drop_pressed()
			return
		elif Input.is_action_just_pressed("cancel"):
			_on_button_cancel_pressed()
			return
		if (_slide_pressed > 10):
			if Input.is_action_pressed("shortcut_left"):
				$Content/Body/SliderQuantity.value -= 1
			elif Input.is_action_pressed("shortcut_right"):
				$Content/Body/SliderQuantity.value += 1
		else :
			if Input.is_action_pressed("shortcut_left") or Input.is_action_pressed("shortcut_right"):
				_slide_pressed += 1
		if Input.is_action_just_released("shortcut_left"):
			$Content/Body/SliderQuantity.value -= 1
			_slide_pressed = 0
		elif Input.is_action_just_released("shortcut_right"):
			$Content/Body/SliderQuantity.value += 1
			_slide_pressed = 0

func open(item:Item, label:String="Transfert"):
	_just_opened = true
	$Content/Body/Buttons/ButtonDrop.text = label
	$Content/Body/LabelName.text = item.label
	$Content/Body/SliderQuantity.max_value = item.quantity
	$Content/Body/SliderQuantity.value = item.quantity
	$Content/Body/LabelQuantity.text = str($Content/Body/SliderQuantity.value)
	visible = true

func _on_slider_quantity_value_changed(value):
	$Content/Body/LabelQuantity.text = str($Content/Body/SliderQuantity.value)

func _on_button_cancel_pressed():
	visible = false

func _on_button_drop_pressed():
	visible = false
	quantity.emit($Content/Body/SliderQuantity.value)

