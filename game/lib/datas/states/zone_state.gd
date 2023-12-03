extends State
class_name ZoneState

var items_removed = PackedStringArray()
var items_added = ItemsCollection.new(false)

func _init(_name:String, _parent:Node=null):
	super(_name, _parent)
