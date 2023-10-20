extends Node
class_name PersistentItemsCollection

var collection_name:String
var collection:ItemsCollection

func _init(_name:String):
	collection_name = _name

func _ready():
	_load()

func add(item:Item):
	collection.add(item)
	_save()
	
func get_bytype(type:Item.ItemType) -> Array:
	return collection.get_bytype(type)
		
func count():
	return collection.count()
	
func _save():
	var save = PackedScene.new()
	save.pack(collection)
	ResourceSaver.save(save, "user://" + collection_name + ".tscn");
	
func _load():
	var save = ResourceLoader.load("user://" + collection_name + ".tscn");
	collection = save.instantiate()
