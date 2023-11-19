extends Node
class_name MessagesList

signal new_message

var messages = []

func have_unread() -> bool:
	for message in messages:
		if (not message.read): return true
	return false

func getbykey(key:String) -> Message:
	for message in messages:
		if (message.key == key): return message
	return null

func add(from, subject, message, key):
	messages.push_back(Message.new(from, subject, message, key))
	new_message.emit()

func saveState(file:FileAccess):
	file.store_64(messages.size())
	for message in messages:
		file.store_pascal_string(message.from)
		file.store_pascal_string(message.subject)
		file.store_pascal_string(message.message)
		file.store_pascal_string(message.key)
		file.store_8(1 if message.read else 0)

func loadState(file:FileAccess):
	var unread = false
	for i in range(file.get_64()):
		var from = file.get_pascal_string()
		var subject = file.get_pascal_string()
		var message = file.get_pascal_string()
		var key = file.get_pascal_string()
		var m = Message.new(from, subject, message, key)
		m.read = file.get_8() == 1
		if (not m.read): unread = true
		messages.push_back(m)
