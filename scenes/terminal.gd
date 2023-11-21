extends Control

signal close(node:Node)

func _on_terminal_screen_close(node):
	close.emit(self)
	visible = false
