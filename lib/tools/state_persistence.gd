extends Node
class_name StatePersistence

const default_ext = ".state"
const default_path = "user://savegames/"

enum {
 	STATE_VARIANT 		= 0,
	STATE_USABLE 		= 1,
	STATE_STRINGARRAY 	= 2,
	STATE_ITEMS			= 3
}

var path = default_path

func _ready():
	DirAccess.make_dir_recursive_absolute(path)
	
func set_path(_path:String):
	path = default_path + _path + "/"
	DirAccess.make_dir_recursive_absolute(path)

func saveState(res:State):
	var file = FileAccess.open(path + res.name + default_ext, FileAccess.WRITE)
	for prop in res.get_property_list():
		if (prop.name == "name"): continue
		if (prop.name == "parent"):
			var parent:Node = res.get("parent")
			if (parent != null):
				for usable in parent.find_children("*", "Usable", true):
					if (usable.save):
						file.store_8(STATE_USABLE)
						file.store_pascal_string(usable.get_path())
						file.store_var(usable.is_used)
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
		elif (prop.type == TYPE_ARRAY):
			file.store_8(STATE_STRINGARRAY)
			file.store_pascal_string(prop.name)
			file.store_32(value.size())
			for v in value: file.store_pascal_string(v)
		elif value is ItemsCollection:
			file.store_8(STATE_ITEMS)
			file.store_pascal_string(prop.name)
			value.saveState(file)
	file.close()
	
func loadState(res:State):
	var parent:Node = res.get("parent")
	var file = FileAccess.open(path + res.name + default_ext, FileAccess.READ)
	if (file == null):
		return null
	while (!file.eof_reached()):
		var entry_type = file.get_8()
		var entry_name = file.get_pascal_string()
		if (entry_type == STATE_VARIANT):
			res.set(entry_name, file.get_var())
		elif (parent != null and entry_type == STATE_USABLE):
			if (file.get_var()):
				var usable = parent.get_node_or_null(entry_name)
				if (usable != null): usable.use()
		elif (parent != null and entry_type == STATE_STRINGARRAY):
			var count = file.get_32()
			var arr = []
			for i in range(count): arr.push_back(file.get_pascal_string())
			res.set(entry_name, arr)
		elif (entry_type == STATE_ITEMS):
			var items:ItemsCollection = res.get(entry_name)
			items.loadState(file)
			
				
	file.close()
		
