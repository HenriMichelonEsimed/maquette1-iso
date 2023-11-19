extends QuestAdvancement
class_name QAMain0

func _init():
	super("QAMain0", null, ["QAMain1"])

func _start():
	GameState.messages.add(
		"Mysterious Man",
		"Hello player", 
		"Congratulation, you have read your first message !\nNow meet me in the security room"
		)
