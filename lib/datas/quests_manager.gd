extends Node
class_name QuestsManager

var _quests = {
	"main": MainQuest.new()
}

func start(quest:String):
	_quests[quest].start()
	
func label(quest:String) -> String:
	return _quests[quest].label
	
func current(quest:String) -> QuestGoal:
	print(_quests[quest].current.key )
	return _quests[quest].current

func event(quest:String, type:Quest.QuestEventType, event_key:String):
	_quests[quest].on_new_quest_event(type, event_key)
	GameState.current_zone.check_quest_advance()

func event_all(type:Quest.QuestEventType, event_key:String):
	for quest in _quests:
		_quests[quest].on_new_quest_event(type, event_key)
	GameState.current_zone.check_quest_advance()

func advpoint(quest:String, key:String):
	_quests[quest].add_advpoint(key)
	
func have_advpoint(quest: String, key:String):
	return _quests[quest].have_advpoint(key)

func get_advpoints(quest: String):
	return _quests[quest].get_advpoints()

func finish_advpoint(quest: String, adv_key:String):
	var adv = _quests[quest].get_advpoint(adv_key)
	if (adv != null):
		adv.finished = true

func saveState(file:FileAccess):
	file.store_64(_quests.size())
	file.store_pascal_string("main")
	_quests["main"].saveState(file)
	
func loadState(file:FileAccess):
	file.get_64()
	file.get_pascal_string()
	_quests["main"].loadState(file)
