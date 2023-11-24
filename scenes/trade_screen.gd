extends Control

signal trade_end(node:Node)

func _on_button_back_pressed():
	trade_end.emit(self)
