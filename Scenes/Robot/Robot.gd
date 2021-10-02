extends Node2D

onready var Pointer = $Pointer
onready var Wheel = $Wheel
onready var look_vector = get_global_mouse_position() - Wheel.global_position

# hook
export(PackedScene) var hook
export(PackedScene) var rocket
var CurrentHook = null
var hooked = false
var hook_initial_max_distance = 0
var hook_max_distance = 0

var bouncy = false

# attributes
export(float) var wheel_velocity = 10
export(float) var hook_velocity = 800
export(float) var hook_force = 50
export(float) var hook_pull_rope_speed = 100
export(float) var rocket_velocity = 800
export(float) var rocket_knockback = 200
export(float) var antigrav_push = 50

var last_velocity = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	look_vector = (get_global_mouse_position() - Wheel.global_position).normalized()
	Pointer.position = Wheel.position
	Pointer.rotation = atan2(look_vector.y, look_vector.x)
	last_velocity = Wheel.linear_velocity
	
	control_wheel(delta)
	control_hook(delta)
	control_rocket()
	control_antigrav()
	control_bounce()


func control_wheel(delta):
	var still = true
	if Input.is_action_pressed("roll_left"):
		Wheel.angular_velocity -= wheel_velocity*delta
		still = false
	
	if Input.is_action_pressed("roll_right"):
		Wheel.angular_velocity += wheel_velocity*delta
		still = false
	
	if still:
		return
		Wheel.linear_velocity.x = 0
		Wheel.linear_velocity.y = 0
		Wheel.angular_velocity = 0


func control_hook(delta):
	if hooked:
		var hook_push = Vector2.ZERO
		if Wheel.position.distance_to(CurrentHook.position) > hook_max_distance:
			hook_push = (Wheel.position.direction_to(CurrentHook.position)*
									hook_force*delta)
		Wheel.linear_velocity += hook_push
		
		if Input.is_action_pressed("hook_pull") and hook_max_distance > 1:
			hook_max_distance -= hook_pull_rope_speed*delta
		elif Input.is_action_pressed("hook_unpull") and hook_max_distance < hook_initial_max_distance:
			hook_max_distance += hook_pull_rope_speed*delta
	
	if Input.is_action_just_pressed("hook"):
		if CurrentHook != null:
			hooked = false
			CurrentHook.queue_free()
			CurrentHook = null
		else:
			CurrentHook = hook.instance()
			add_child(CurrentHook)
			move_child(CurrentHook, get_parent().get_child_count()-1)
			CurrentHook.position = Wheel.position
			CurrentHook.connect('hook_attached', self, 'hook_attached')
			CurrentHook.shoot(look_vector*hook_velocity)


func control_rocket():
	if Input.is_action_just_pressed("rocket"):
		var new = rocket.instance()
		add_child(new)
		move_child(new, get_child_count()-1)
		new.position = Wheel.position
		new.shoot(look_vector*hook_velocity)
		Wheel.apply_impulse(Vector2.ZERO, -look_vector*rocket_knockback)


func control_antigrav():
	if Input.is_action_just_pressed("toggle_grav"):
		Wheel.gravity_scale *= -1
		Wheel.linear_velocity += Vector2.DOWN * Wheel.gravity_scale * antigrav_push


func control_bounce():
	if Input.is_action_just_pressed("toggle_bounce"):
		bouncy = !bouncy
		if bouncy:
			Wheel.linear_damp = 0


func hook_attached():
	hooked = true
	hook_initial_max_distance = min(250, Wheel.position.distance_to(CurrentHook.position))
	hook_max_distance = hook_initial_max_distance


func _on_Wheel_on_collision(collision_normal):
	if bouncy:
		var bounce_direction = collision_normal.normalized()
		var velocity_projection = last_velocity.dot(-bounce_direction)
		if velocity_projection > 0:
			last_velocity -= last_velocity.project(-bounce_direction)
			Wheel.linear_velocity = last_velocity + bounce_direction * min(1000, velocity_projection * 1.2)
