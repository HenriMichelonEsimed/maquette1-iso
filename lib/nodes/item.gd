extends Node3D
class_name Item

enum ItemType {
	ITEM_TOOL			= 1,
	ITEM_CLOTHES 		= 2,
	ITEM_CONSUMABLES	= 3,
	ITEM_AMMUNITIONS	= 4,
	ITEM_MISCELLANEOUS	= 5
	}

@export var key:String
@export var label:String
@export var weight:int
@export var indestructible = false
var type:ItemType
