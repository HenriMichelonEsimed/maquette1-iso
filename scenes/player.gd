extends CharacterBody3D

var speed = 12
var jump_impulse = 15
var fall_acceleration = 80
var target_velocity = Vector3.ZERO
var last_collision = null
var current_view = 0

const directions = {
	"forward" : 	[  { 'x':  1, 'z': -1 },  { 'x':  1, 'z':  1 },  { 'x': -1, 'z':  1 },  { 'x': -1, 'z': -1 } ],
	"left" : 		[  { 'x': -1, 'z': -1 },  { 'x':  1, 'z': -1 },  { 'x':  1, 'z':  1 },  { 'x': -1, 'z':  1 } ],
	"backward" : 	[  { 'x': -1, 'z':  1 },  { 'x': -1, 'z': -1 },  { 'x':  1, 'z': -1 },  { 'x':  1, 'z':  1 } ],
	"right" : 		[  { 'x':  1, 'z':  1 },  { 'x': -1, 'z':  1 },  { 'x': -1, 'z': -1 },  { 'x':  1, 'z': -1 } ]
}

func _physics_process(delta):
	var no_jump = false
	var direction = Vector3.ZERO
	if Input.is_action_pressed("player_right"):
		direction.x += directions["right"][current_view].x
		direction.z += directions["right"][current_view].z
	if Input.is_action_pressed("player_left"):
		direction.x += directions["left"][current_view].x
		direction.z += directions["left"][current_view].z
	if Input.is_action_pressed("player_backward"):
		direction.x += directions["backward"][current_view].x
		direction.z += directions["backward"][current_view].z
	if Input.is_action_pressed("player_forward"):
		direction.x += directions["forward"][current_view].x
		direction.z += directions["forward"][current_view].z
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		look_at(position + direction, Vector3.UP)
		for index in range(get_slide_collision_count()):
			var collision = get_slide_collision(index)
			var collider = collision.get_collider()
			if collider == null:
				continue
			if collider.is_in_group("stairs"):
				target_velocity.y = 5
			elif collider.is_in_group("ladders") and Input.is_action_pressed("player_jump"):
				target_velocity.y = 12
				no_jump = true
			elif collider.is_in_group("usables"):
				last_collision = collision
			elif collider.is_in_group("triggers"):
				collider.call("trigger")
			
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if (last_collision != null) and Input.is_action_pressed("player_use"):
		last_collision.get_collider().call("use")
		last_collision = null
	
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	if is_on_floor() and Input.is_action_just_pressed("player_jump") and !no_jump:
		target_velocity.y = jump_impulse
	
	velocity = target_velocity
	move_and_slide()


func _on_camera_view_rotate(view:int):
	current_view = view
