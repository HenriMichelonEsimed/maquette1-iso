extends Control

signal close(node:Node)
signal load_savegame(savegame:String)

@onready var listSaves = $Content/VBoxContainer/ListSavegames

var saves = {}
var savegame:String

func _ready():
	for dir in StateSaver.get_savegames():
		listSaves.add_item(tr("[Auto save]") if dir==StatePersistence.autosave_path else dir)
		listSaves.set_item_metadata(listSaves.item_count-1, dir)
	listSaves.select(0)

func _on_list_savegames_item_clicked(index, at_position, mouse_button_index):
	savegame = listSaves.get_item_metadata(index)

func _on_button_close_pressed():
	close.emit(self)

func _on_button_load_pressed():
	load_savegame.emit(savegame)
