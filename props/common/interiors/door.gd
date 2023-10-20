extends Usable

func _init():
	super(true)

func _use():
	rotate(Vector3.UP, PI / 2)
