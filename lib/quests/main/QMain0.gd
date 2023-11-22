extends QuestGoal
class_name QMain0

func _init():
	super("QMain0", "",
	"Read your first message on your phone")

func _start():
	GameState.messages.add(
		"Mysterious Person",
		"Hello, player",
		"Congratulations, you have read your first message !\nNow meet me in the Restricted Area",
		key
		)

func success():
	var msg = GameState.messages.getbykey(key)
	if (msg != null) and msg.read:
		return "QMain1"
	return null

