extends QuestGoal

var end = false

func _init():
	super("QMain1", "QMain0",
	"Meet the Mysterious Person is the Restricted Area")

func on_new_quest_event(type:Quest.QuestEventType, key:String):
	if (type == Quest.QuestEventType.QUESTEVENT_TALK) and (key == "QMain1_end"):
		end = true

func success():
	if (end): return "QMainZ"
