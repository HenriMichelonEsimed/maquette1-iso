extends Node
class_name EventsQueue

var _queue = {}
	
func postEvent(zone:String,target:String,event:String):
	if (!_queue.has(zone)):
		_queue[zone] = []
	_queue[zone].push_back(PostponedEvent.new(target, event))
	
func getNextEvent(zone:String) -> PostponedEvent:
	if (!_queue.has(zone)): 
		return null
	return _queue[zone].pop_front()
	
func saveState(file:FileAccess):
	file.store_64(_queue.size())
	for zone in _queue:
		var events = _queue[zone]
		file.store_pascal_string(zone)
		file.store_64(events.size())
		for event in events:
			file.store_pascal_string(event.target)
			file.store_pascal_string(event.event)

func loadState(file:FileAccess):
	for i in range(file.get_64()):
		var zone = file.get_pascal_string()
		_queue[zone] = []
		for j in range(file.get_64()):
			postEvent(zone, file.get_pascal_string(), file.get_pascal_string())
