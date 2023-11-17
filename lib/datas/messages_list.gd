extends Node
class_name MessagesList

var messages = []

func saveState(file:FileAccess):
	file.store_64(messages.size())
	for message in messages:
		file.store_pascal_string(message.subject)
		file.store_pascal_string(message.message)

func loadState(file:FileAccess):
	for i in range(file.get_64()):
		var subject = file.get_pascal_string()
		var message = file.get_pascal_string()
		messages.push_back(Message.new(subject, message))
