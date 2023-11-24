extends Control

signal close(node:Node)
signal load_savegame(savegame:String)

@onready var listSaves = $Content/VBoxContainer/ListSavegames

var saves = {}
var savegame:String

func _ready():
	listSaves.add_item(tr("Last save"))
	listSaves.set_item_metadata(0, "")
	var dirs = StateSaver.get_savegames()
	dirs.reverse()
	for dir in dirs:
		var time = Time.get_datetime_dict_from_unix_time(StateSaver.get_savegame_time(dir))
		var item: String
		if (GameState.settings.lang == "en") : 
			item = "%04d/%02d/%02d %02d:%02d" % [time.year, time.day, time.month, time.hour, time.minute]
		else:
			item = "%04d/%02d/%02d %02d:%02d" % [time.year, time.month, time.day, time.hour, time.minute]
		listSaves.add_item(item)
		listSaves.set_item_metadata(listSaves.item_count-1, dir)

func _on_list_savegames_item_clicked(index, at_position, mouse_button_index):
	savegame = StateSaver.format_savegame_name(listSaves.get_item_metadata(index))

func _on_button_close_pressed():
	close.emit(self)

func _on_button_load_pressed():
	load_savegame.emit(savegame)
