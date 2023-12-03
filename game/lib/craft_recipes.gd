extends Node

const recipes = {
	"ham_sandwich_2_pickels": [ Item.ItemType.ITEM_CONSUMABLES, [
		"ham_sandwich_2", "pickle_1", "pickle_1"
	]]
}
var ingredients:Dictionary = {}

func _ready():
	for target in recipes:
		var target_ingredients = recipes[target][1]
		for ingredient in target_ingredients:
			if ingredients.has(ingredient) and ingredients[ingredient].find(target) == -1:
				ingredients[ingredient].push_back(target)
			else:
				ingredients[ingredient] = [ target ]
	pass
