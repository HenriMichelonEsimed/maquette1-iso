extends Node
class_name MessagesList

signal new_message

var messages = []

func add(subject, message):
	messages.push_back(Message.new(subject, message))
	new_message.emit()

func saveState(file:FileAccess):
	file.store_64(messages.size())
	for message in messages:
		file.store_pascal_string(message.subject)
		file.store_pascal_string(message.message)
		file.store_8(1 if message.read else 0)

func loadState(file:FileAccess):
	var unread = false
	for i in range(file.get_64()):
		var subject = file.get_pascal_string()
		var message = file.get_pascal_string()
		var m = Message.new(subject, message)
		m.read = file.get_8() == 1
		if (not m.read): unread = true
		messages.push_back(m)
	if (unread):
		new_message.emit()
