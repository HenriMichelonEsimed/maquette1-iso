extends Node
class_name QuestEvents

signal questevent(type:QuestEventType, key:String)

enum QuestEventType {
	QUESTEVENT_READMESSAGE	= 0
	}

func event(type:QuestEventType, key:String):
	questevent.emit(type, key)