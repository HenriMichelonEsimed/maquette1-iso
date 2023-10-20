extends CharacterBody3D

var speed = 12
var jump_impulse = 15
var fall_acceleration = 80
var target_velocity = Vector3.ZERO
var last_collision = null

func _physics_process(delta):
	var no_jump = false
	var direction = Vector3.ZERO
	if Input.is_action_pressed("player_right"):
		direction.x += 1
		direction.z += 1
	if Input.is_action_pressed("player_left"):
		direction.x -= 1
		direction.z -= 1
	if Input.is_action_pressed("player_backward"):
		direction.z += 1
		direction.x -= 1
	if Input.is_action_pressed("player_forward"):
		direction.z -= 1
		direction.x += 1
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
