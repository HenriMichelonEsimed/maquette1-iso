extends Control

signal close(node:Node)
signal load_savegame(savegame:String)

@onready var listSaves = $Content/VBoxContainer/ListSavegames

var saves = {}
var savegame = null

func _ready():
	listSaves.clear()
	for dir in StateSaver.get_savegames():
		listSaves.add_item(tr("[Auto save]") if dir==StatePersistence.autosave_path else dir)
		listSaves.set_item_metadata(listSaves.item_count-1, dir)
	listSaves.select(0)
	listSaves.grab_focus()

func _process(delta):
	if (Input.is_action_just_pressed("cancel")):
		_on_button_close_pressed()

func _on_list_savegames_item_selected(index):
	savegame = listSaves.get_item_metadata(index)

func _on_button_close_pressed():
	close.emit(self)
	queue_free()

func _on_button_load_pressed():
	if (savegame != null): 
		load_savegame.emit(savegame)
		queue_free()

func _on_button_delete_pressed():
	if (savegame != null): 
		var dlg = Tools.load_dialog(self, "dialogs/confirm_dialog")
		dlg.connect("confirm", _on_confirm_delete)
		dlg.open("Delete ?", tr("Delete saved game ' %s' ?") % savegame)
		
func _on_confirm_delete(confirm:bool):
	if confirm:
		StateSaver.delete(savegame)
		_ready()
