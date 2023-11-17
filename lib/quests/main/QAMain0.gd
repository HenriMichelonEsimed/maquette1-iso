extends QuestAdvancement
class_name QAMain0

func _init():
	super("QAMain0", null, ["QAMain1"])

func _start():
	GameState.messages.messages.push_back(Message.new("SUbject 1", "Message body 1"))
