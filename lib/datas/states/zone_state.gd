extends State
class_name ZoneState

var items_removed:Array = []
var items_added = ItemsCollection.new()

func _init(_name:String, _parent:Node=null):
	super(_name, _parent)
