extends Node
class_name QuestEvents

signal questevent(type:QuestEventType, key:String)

enum QuestEventType {
	QUESTEVENT_READMESSAGE	= 0,
	QUESTEVENT_TALK			= 1,
	QUESTEVENT_ADVPOINT		= 2,
}

func event(type:QuestEventType, key:String):
	questevent.emit(type, key)
