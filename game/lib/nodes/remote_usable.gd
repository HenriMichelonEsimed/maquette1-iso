extends Usable
class_name RemoteUsable

func _init():
	super(false)

func use(byplayer:bool=false,startup:bool=false):
	if (!startup and byplayer): return
	super.use(byplayer, startup)
