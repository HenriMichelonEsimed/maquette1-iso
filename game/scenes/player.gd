extends CharacterBody3D
class_name Player

const walking_speed = 7
const running_speed = 14
const walking_jump_impulse = 20

signal player_moving()
signal player_stopmoving()
signal reset_position()
signal display_info(node:Node3D)
signal hide_info()
signal item_collected(item:Item,quantity:int)

@onready var anim = $AnimationPlayer
@onready var raycast = $RayCast3D

var speed = 0
var fall_acceleration = 200
var target_velocity = Vector3.ZERO
var last_collision = null
var current_view = 0
var item_to_collect:Item = null
var node_to_use:Usable = null
var char_to_talk:InteractiveCharacter = null
var signaled = false
var move_to_target = null
var move_to_previous_position = null
var collect_items = []

const directions = {
	"forward" : 	[  { 'x':  1, 'z': -1 },  { 'x':  1, 'z':  1 },  { 'x': -1, 'z':  1 },  { 'x': -1, 'z': -1 } ],
	"left" : 		[  { 'x': -1, 'z': -1 },  { 'x':  1, 'z': -1 },  { 'x':  1, 'z':  1 },  { 'x': -1, 'z':  1 } ],
	"backward" : 	[  { 'x': -1, 'z':  1 },  { 'x': -1, 'z': -1 },  { 'x':  1, 'z': -1 },  { 'x':  1, 'z':  1 } ],
	"right" : 		[  { 'x':  1, 'z':  1 },  { 'x': -1, 'z':  1 },  { 'x': -1, 'z': -1 },  { 'x':  1, 'z': -1 } ]
}

func move_to(target:Vector2, camera:Camera3D):
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = camera.project_ray_origin(target)
	ray_query.to = ray_query.from + camera.project_ray_normal(target) * 1000
	var iray = get_world_3d().direct_space_state.intersect_ray(ray_query)
	if (iray.size() > 0):
		move_to_target = iray.position
	
func use(target:Vector2, camera:Camera3D):
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = camera.project_ray_origin(target)
	ray_query.to = ray_query.from + camera.project_ray_normal(target) * 1000
	var iray = get_world_3d().direct_space_state.intersect_ray(ray_query)
	if (iray.size() > 0):
		var dist = global_position.distance_to(iray.collider.global_position)
		var use_min_dist = 1.8
		if iray.collider is InteractiveCharacter:
			use_min_dist = 2.5
		if (dist < use_min_dist):
			_on_collect_item_aera_body_entered(iray.collider)
			action_use()
			_on_collect_item_aera_body_exited(iray.collider)

func stop_move_to():
	if (move_to_target != null):
		move_to_target = null
		velocity = Vector3.ZERO
		anim.play("standing")

func _look_at(node:Node3D):
	var pos = node.global_position
	pos.y = position.y
	look_at(pos)

func action_use():
	if (node_to_use != null):
		_look_at(node_to_use)
		node_to_use.use(true)
	elif (item_to_collect != null):
		_look_at(item_to_collect)
		item_collected.emit(item_to_collect,-1)
	elif (char_to_talk != null):
		_look_at(char_to_talk)
		char_to_talk.interact()

func _process(_delta):
	if (GameState.paused): return
	if Input.is_action_just_pressed("player_use_nomouse"):
		action_use()
		return

func _physics_process(delta):
	if (GameState.paused): return
	if (position.y < -100) :
		reset_position.emit()
		return
	var on_floor = is_on_floor_only() 
	if (move_to_target != null):
		if Input.is_action_pressed("player_right") or  Input.is_action_pressed("player_left") or  Input.is_action_pressed("player_backward") or  Input.is_action_pressed("player_forward"):
			stop_move_to()
		else:
			var look_at_target = move_to_target
			look_at_target.y = position.y
			look_at(look_at_target)
			if (transform.origin.distance_to(move_to_target)) < 0.1:
				stop_move_to()
				return
			if Input.is_action_pressed("modifier"):
				if (anim.current_animation != "running"):
					speed = running_speed
					anim.play("running")
			else:
				speed = walking_speed
				anim.play("walking")
			velocity = -transform.basis.z * speed
			
			if (move_to_target.y > position.y):
				for index in range(get_slide_collision_count()):
					var collision = get_slide_collision(index)
					var collider = collision.get_collider()
					if collider.is_in_group("stairs"):
						velocity.y = 8
			elif not on_floor:
				velocity.y = velocity.y - (fall_acceleration * 2 * delta)
			move_to_previous_position = position
			move_and_slide()
			if (position.distance_to(move_to_previous_position) < 0.001):
				stop_move_to()
				return
			if !anim.is_playing():
				anim.play()
			GameState.view_pivot.position = position
			GameState.view_pivot.position.y += 1.5
			return
		
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
		if Input.is_action_pressed("modifier"):
			if (anim.current_animation != "running"):
				speed = running_speed
				anim.play("running")
		else:
			speed = walking_speed
			anim.play("walking")
		if !anim.is_playing():
			anim.play()
		for index in range(get_slide_collision_count()):
			var collision = get_slide_collision(index)
			var collider = collision.get_collider()
			if collider == null:
				continue
			if collider.is_in_group("stairs"):
				target_velocity.y = 8
				no_jump = true
			elif collider.is_in_group("ladders") and Input.is_action_pressed("player_jump"):
				target_velocity.y = 12
				no_jump = true
	else:
		target_velocity.y = 0
		signaled = false
		player_stopmoving.emit()
		anim.play("standing")
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if not on_floor:
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	if on_floor and Input.is_action_just_pressed("player_jump") and !no_jump:
		target_velocity.y = walking_jump_impulse
		#anim.play("jumping")
	velocity = target_velocity
	move_and_slide()
	if direction != Vector3.ZERO:
		GameState.view_pivot.position = position
		GameState.view_pivot.position.y += 1.5
		if (!signaled) :
			player_moving.emit()
			signaled = true

func get_floor_collision():
	raycast.force_raycast_update()
	return raycast.get_collision_point()

func _on_camera_view_rotate(view:int):
	current_view = view

func _on_collect_item_aera_body_entered(node:Node):
	collect_items.push_back(node)
	if item_to_collect == null:
		_collect()

func _collect():
	if (collect_items.is_empty()): return
	var node = collect_items.pop_back()
	if (node is Item):
		item_to_collect = node
		display_info.emit(node)
	elif (node is Usable):
		node_to_use = node
		display_info.emit(node)
	elif (node is Trigger):
		node.trigger()
	elif (node is InteractiveCharacter):
		char_to_talk = node
		display_info.emit(node)

func _on_collect_item_aera_body_exited(_node:Node):
	item_to_collect = null
	node_to_use = null
	char_to_talk = null
	hide_info.emit()
	_collect()

func _on_view_pivot_view_moving():
	signaled = false

