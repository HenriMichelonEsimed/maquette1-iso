extends Node
class_name StatePersistence

const default_ext = ".state"
const default_path = "user://savegames/"
const autosave_path = "autosave"
const backup_path = "backup/"

enum {
 	STATE_VARIANT 		= 0,
	STATE_USABLE 		= 1,
	STATE_FUNCTIONAL	= 2,
	STATE_STRINGARRAY 	= 3,
	STATE_ITEMS			= 4,
	STATE_EVENTS		= 5,
	STATE_MESSAGES		= 6,
	STATE_QUEST			= 7
}

var _path:String
const max_backup = 19

func _ready():
	set_path(autosave_path)
	DirAccess.make_dir_recursive_absolute(default_path + autosave_path)
	DirAccess.make_dir_recursive_absolute(default_path + backup_path)

func get_savegames():
	return DirAccess.get_directories_at(default_path + backup_path)

func get_savegame_time(savegame:String):
	return FileAccess.get_modified_time(default_path + backup_path + savegame)
	
func format_savegame_name(savegame:String):
	if (savegame == ""):
		return autosave_path
	return backup_path + savegame

func set_path(_p:String = autosave_path):
	_path = default_path + _p

func _format_name(name:String):
	return name.replace("/", "_")
	
func backup():
	var dirs = DirAccess.get_directories_at(default_path + backup_path)
	if (dirs.size() > max_backup):
		for i in range(0, dirs.size() - max_backup):
			var path_to_remove = default_path + backup_path + dirs[i]
			OS.move_to_trash(ProjectSettings.globalize_path(path_to_remove))
	var new_path = default_path + backup_path + Time.get_datetime_string_from_system().replace(":", "").replace("-", "") + "/"
	var files = DirAccess.get_files_at(_path)
	if (files.size() > 0):
		DirAccess.make_dir_recursive_absolute(new_path)
		for file in DirAccess.get_files_at(_path):
			DirAccess.copy_absolute(_path + "/" + file, new_path + file)

func saveState(res:State):
	var filename = _path + "/" + _format_name(res.name) + default_ext
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if (file == null): 
		return false
	for prop in res.get_property_list():
		if (prop.name == "name"): continue
		if (prop.name == "parent"):
			var parent:Node = res.get("parent")
			if (parent != null):
				for node in parent.find_children("*", "Usable", true, false):
					if (node.save):
						file.store_8(STATE_USABLE)
						file.store_pascal_string(node.get_path())
						file.store_8(1 if node.is_used else 0)
				for node in parent.find_children("*", "Functional", true, false):
					if (node.save):
						file.store_8(STATE_FUNCTIONAL)
						file.store_pascal_string(node.get_path())
						file.store_var(node.is_used)
			continue
		var value = res.get(prop.name)
		if (prop.type == TYPE_STRING 
			or prop.type == TYPE_BOOL
			or prop.type == TYPE_FLOAT
			or prop.type == TYPE_VECTOR3
			or prop.type == TYPE_INT):
			file.store_8(STATE_VARIANT)
			file.store_pascal_string(prop.name)
			file.store_var(value)
		elif (value is PackedStringArray):
			file.store_8(STATE_STRINGARRAY)
			file.store_pascal_string(prop.name)
			file.store_var(value)
		elif value is ItemsCollection:
			file.store_8(STATE_ITEMS)
			file.store_pascal_string(prop.name)
			value.saveState(file)
		elif value is EventsQueue:
			file.store_8(STATE_EVENTS)
			file.store_pascal_string(prop.name)
			value.saveState(file)
		elif value is MessagesList:
			file.store_8(STATE_MESSAGES)
			file.store_pascal_string(prop.name)
			value.saveState(file)
		elif value is QuestsManager:
			file.store_8(STATE_QUEST)
			file.store_pascal_string(prop.name)
			value.saveState(file)
	file.close()
	return true
	
func loadState(res:State):
	var parent:Node = res.get("parent")
	var filename = _path + "/" + _format_name(res.name) + default_ext
	var file = FileAccess.open(filename, FileAccess.READ)
	if (file == null):
		print(FileAccess.get_open_error())
		return null
	while (!file.eof_reached()):
		var entry_type = file.get_8()
		var entry_name = file.get_pascal_string()
		if (entry_type in [STATE_VARIANT, STATE_STRINGARRAY]):
			res.set(entry_name, file.get_var())
		elif (parent != null 
			and entry_type in [STATE_USABLE, STATE_FUNCTIONAL]):
			var is_used = file.get_8() == 1
			var usable = parent.get_node_or_null(entry_name)
			if (usable != null) and is_used: 
				usable.use(false, true)
		elif (entry_type == STATE_ITEMS):
			var items:ItemsCollection = res.get(entry_name)
			items.loadState(file)
		elif (entry_type == STATE_EVENTS):
			var queue:EventsQueue = res.get(entry_name)
			queue.loadState(file)
		elif (entry_type == STATE_MESSAGES):
			var queue:MessagesList = res.get(entry_name)
			queue.loadState(file)
		elif (entry_type == STATE_QUEST):
			var queue:QuestsManager = res.get(entry_name)
			queue.loadState(file)
	file.close()

