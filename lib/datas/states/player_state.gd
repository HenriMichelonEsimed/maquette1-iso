extends State
class_name PlayerState

var current_tool_type:Item.ItemType = -1
var current_tool_key:String = ""

func _init():
	super("player")
