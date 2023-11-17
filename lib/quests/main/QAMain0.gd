extends QuestAdvancement
class_name QAMain0

func _init():
	super("QAMain0", null, ["QAMain1"])

func _start():
	GameState.messages.add(
		"Hello player", 
		"Congratulation, you have read your first message !\n"
		)
