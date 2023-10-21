extends State
class_name GameState

var zone_name:String = "PM/pm_1"
var position:Vector3 = Vector3.ZERO
var rotation:Vector3 = Vector3.ZERO
var player_inventory = ItemsCollection.new()

func _init():
	super("game")
