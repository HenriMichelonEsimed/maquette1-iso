extends Node

signal new_notification(message:String)

func notif(message:String):
	new_notification.emit(message)
