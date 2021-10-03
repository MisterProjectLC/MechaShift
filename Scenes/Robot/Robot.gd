extends Node2D

onready var Pointer = $Pointer
onready var Wheel = $Wheel
onready var look_vector = get_global_mouse_position() - Wheel.global_position
export(NodePath) var CooldownManagerPath
onready var CooldownManager = get_node(CooldownManagerPath)

# hook
export(PackedScene) var hook
export(PackedScene) var rocket
var CurrentHook = null
var hooked = false
var hook_initial_max_distance = 0
var hook_max_distance = 0

var bouncy = false
var teleport_pos = Vector2.ZERO
var stored_gravity = 0
var stored_charge = 0

# attributes
export(float) var wheel_velocity = 10
export(float) var hook_velocity = 800
export(float) var hook_force = 50
export(float) var hook_pull_rope_speed = 100
export(float) var rocket_velocity = 800
export(float) var rocket_knockback = 200
export(float) var bounce_inital_push = 50
export(float) var charge_multiplier = 100
export(float) var charge_load_rate = 20

var last_velocity = Vector2.ZERO


func _process(delta):
	update()


func _draw():
	if CurrentHook == null:
		return
	
	var pos_a = Wheel.position
	var pos_b = CurrentHook.position
	draw_line(pos_a, pos_b, Color.greenyellow)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	look_vector = (get_global_mouse_position() - Wheel.global_position).normalized()
	Pointer.position = Wheel.position
	Pointer.rotation = atan2(look_vector.y, look_vector.x)
	last_velocity = Wheel.linear_velocity
	
	$Head.position = Wheel.position
	
	control_wheel(delta)
	control_hook(delta)
	control_rocket()
	control_antigrav()
	control_bounce()
	control_teleport()
	control_charge(delta)


func control_wheel(delta):
	var still = true
	if Input.is_action_pressed("roll_left"):
		Wheel.angular_velocity -= wheel_velocity*delta * clamp(Wheel.gravity_scale, -1, 1)
	elif Wheel.angular_velocity * Wheel.gravity_scale < 0:
		Wheel.angular_velocity = 0
	
	if Input.is_action_pressed("roll_right"):
		Wheel.angular_velocity += wheel_velocity*delta * clamp(Wheel.gravity_scale, -1, 1)
	elif Wheel.angular_velocity * Wheel.gravity_scale > 0:
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
		set_hook(CurrentHook == null)


func set_hook(value):
	if !value:
		hooked = false
		if CurrentHook != null:
			CurrentHook.queue_free()
		CurrentHook = null
	elif not CooldownManager.get_overload(Global.HOOK):
		CurrentHook = hook.instance()
		add_child(CurrentHook)
		move_child(CurrentHook, get_parent().get_child_count()-1)
		CurrentHook.position = Wheel.position
		CurrentHook.connect('hook_attached', self, 'hook_attached')
		CurrentHook.shoot(look_vector*hook_velocity)
		increase_cooldown(Global.HOOK)


func control_rocket():
	if Input.is_action_just_pressed("rocket") and not CooldownManager.get_overload(Global.ROCKET):
		var new = rocket.instance()
		add_child(new)
		move_child(new, get_child_count()-1)
		new.position = Wheel.position
		new.shoot(look_vector*hook_velocity)
		Wheel.apply_impulse(Vector2.ZERO, -look_vector*rocket_knockback)
		increase_cooldown(Global.ROCKET)


func control_antigrav():
	if Input.is_action_just_pressed("toggle_grav") and not CooldownManager.get_overload(Global.ANTI):
		Wheel.gravity_scale *= -1
		increase_cooldown(Global.ANTI)
		
		if Wheel.gravity_scale < 0:
			$Head.rotation = 180
		else:
			$Head.rotation = 0


func control_bounce():
	if Input.is_action_just_pressed("toggle_bounce"):
		set_bouncy(!bouncy)

func set_bouncy(value):
	bouncy = value
	if bouncy:
		Wheel.apply_impulse(Vector2.ZERO, Vector2(0, Wheel.gravity_scale*bounce_inital_push))
		Wheel.linear_damp = 0
	else:
		Wheel.linear_damp = 0.1


func hook_attached():
	hooked = true
	hook_initial_max_distance = min(250, Wheel.position.distance_to(CurrentHook.position))
	hook_max_distance = hook_initial_max_distance


func control_teleport():
	if Input.is_action_just_pressed("teleport") and not CooldownManager.get_overload(Global.TELEPORT):
		teleport_pos = get_global_mouse_position()
		increase_cooldown(Global.TELEPORT)
		$AnimationPlayer.play("TeleportBegin")


func control_charge(delta):
	if not CooldownManager.get_overload(Global.CHARGE):
		if stored_charge < 100 and Input.is_action_pressed("charge"):
			Wheel.linear_velocity -= Wheel.linear_velocity*0.45*delta
			stored_charge += delta*charge_load_rate
		elif Input.is_action_just_released("charge"):
			if stored_charge > 0:
				Wheel.apply_impulse(Vector2.ZERO, look_vector*stored_charge*charge_multiplier)
				increase_cooldown(Global.CHARGE)
				stored_charge = 0


func _on_Wheel_on_collision(collision_normal):
	if bouncy and not CooldownManager.get_overload(Global.BOUNCE):
		var bounce_direction = collision_normal.normalized()
		var velocity_projection = last_velocity.dot(-bounce_direction)
		if velocity_projection > 0:
			last_velocity -= last_velocity.project(-bounce_direction)
			Wheel.linear_velocity = last_velocity + bounce_direction * min(1000, velocity_projection * 1.3)
			if velocity_projection * 1.3 > 1:
				increase_cooldown(Global.BOUNCE)


func increase_cooldown(type):
	CooldownManager.increase_cooldown(type)


func _on_CooldownManager_overloaded(type):
	if type == Global.BOUNCE:
		set_bouncy(false)
	elif type == Global.HOOK:
		set_hook(false)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "TeleportBegin":
		Wheel.global_position = teleport_pos
		$AnimationPlayer.play("TeleportEnd")
