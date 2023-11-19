extends QuestAdvancement

var end = false

func _init():
	super("QAMain1", "QAMain0",
	"Meet the Mysterious Man is the Restricted Area")

func on_new_quest_event(type:QuestEvents.QuestEventType, key:String):
	if (type == QuestEvents.QuestEventType.QUESTEVENT_TALK) and (key == "QAMain1_end"):
		end = true

func success():
	if (end): return "QAMainZ"
