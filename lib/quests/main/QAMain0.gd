extends QuestAdvancement
class_name QAMain0

func _init():
	super("QAMain0", "",
	"Read your first message on your phone")

func _start():
	GameState.messages.add(
		"Mysterious Person",
		"Hello player", 
		"Congratulation, you have read your first message !\nNow meet me in the Restricted Area",
		key
		)

func success():
	var msg = GameState.messages.getbykey(key)
	if (msg != null) and msg.read:
		return "QAMain1"
	return null

