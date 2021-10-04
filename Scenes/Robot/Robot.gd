extends Node2D

onready var Pointer = $Pointer
onready var Wheel = $Wheel
onready var WheelCamera = $Wheel/Camera2D
onready var look_vector = get_global_mouse_position() - Wheel.global_position
export(NodePath) var CooldownManagerPath
export(NodePath) var UIPath
onready var CooldownManager = get_node(CooldownManagerPath)
onready var UI = get_node(UIPath)
var damage = 0
var max_damage = 3

# hook
export(PackedScene) var hook
export(PackedScene) var rocket
var CurrentHook = null
var hooked = false
var hook_initial_max_distance = 0
var hook_max_distance = 0

var _bouncy = false
var _teleport_pos = Vector2.ZERO
var _stored_gravity = 0
var _stored_charge = 0
var overload_active = true

# attributes
export(float) var wheel_velocity = 10
export(float) var hook_velocity = 900
export(float) var hook_force = 50
export(float) var hook_pull_rope_speed = 100
export(float) var rocket_velocity = 700
export(float) var rocket_knockback = 200
export(float) var bounce_inital_push = 50
export(float) var charge_multiplier = 20
export(float) var charge_load_rate = 50
export(float) var camera_limit_speed = 400
export(PackedScene) var explosion

var last_velocity = Vector2.ZERO

var deactivation_enabled = true


func _process(delta):
	update()
	
	WheelCamera.limit_left += camera_limit_speed*delta
	if (WheelCamera.limit_left > Wheel.position.x or 
	WheelCamera.limit_top > Wheel.position.y or Wheel.position.y > WheelCamera.limit_bottom):
		damage += delta
		UI.set_blackout(damage/max_damage)
		if damage > max_damage:
			get_tree().reload_current_scene()
	else:
		damage = 0
		UI.set_blackout(0)


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
	control_overload()


func control_wheel(delta):
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
		$sfx_shoot_hook.play(0.0)
		CurrentHook = hook.instance()
		add_child(CurrentHook)
		move_child(CurrentHook, get_parent().get_child_count()-1)
		CurrentHook.position = Pointer.position
		CurrentHook.connect('hook_attached', self, 'hook_attached')
		CurrentHook.shoot(look_vector*hook_velocity)
		increase_cooldown(Global.HOOK)


func control_rocket():
	if Input.is_action_just_pressed("rocket") and not CooldownManager.get_overload(Global.ROCKET):
		$sfx_shoot.play(0.0)
		var new = rocket.instance()
		add_child(new)
		move_child(new, get_child_count()-1)
		new.position = Pointer.position
		new.shoot(look_vector*rocket_velocity)
		Wheel.apply_impulse(Vector2.ZERO, -look_vector*rocket_knockback)
		increase_cooldown(Global.ROCKET)


func control_antigrav():
	if Input.is_action_just_pressed("toggle_grav") and not CooldownManager.get_overload(Global.ANTI):
		Wheel.gravity_scale *= -1
		increase_cooldown(Global.ANTI)
		
		if Wheel.gravity_scale < 0:
			$sfx_grav_on.play()
			$Head.rotation_degrees = 180
		else:
			$sfx_grav_off.play()
			$Head.rotation_degrees = 0


func control_bounce():
	if Input.is_action_just_pressed("toggle_bounce") and not CooldownManager.get_overload(Global.BOUNCE):
		set_bouncy(!_bouncy)



func set_bouncy(value):
	_bouncy = value
	if _bouncy:
		$sfx_bounce_on.play()
		Wheel.apply_impulse(Vector2.ZERO, Vector2(0, -Wheel.gravity_scale*bounce_inital_push))
		Wheel.linear_damp = 0
	else:
		$sfx_bounce_off.play()
		Wheel.linear_damp = 0.1


func hook_attached():
	hooked = true
	hook_initial_max_distance = min(250, Wheel.position.distance_to(CurrentHook.position))
	hook_max_distance = hook_initial_max_distance


func control_teleport():
	if Input.is_action_just_pressed("teleport") and not CooldownManager.get_overload(Global.TELEPORT):
		$sfx_teleport.play()
		_teleport_pos = get_global_mouse_position()
		increase_cooldown(Global.TELEPORT)
		Wheel.linear_velocity = Vector2.ZERO
		$AnimationPlayer.play("TeleportBegin")


func control_charge(delta):
	if not CooldownManager.get_overload(Global.CHARGE):
		if Input.is_action_pressed("charge"):
			if _stored_charge < 100:
				$sfx_charge.play(1.0)
				Wheel.linear_velocity -= Wheel.linear_velocity*0.45*delta
				_stored_charge += delta*charge_load_rate
				$Pointer/ChargeBar.visible = true
				$Pointer/ChargeBar.value = _stored_charge
			
		elif Input.is_action_just_released("charge"):
			$sfx_charge.stop()
			if _stored_charge > 0:
				$sfx_charge_blast.play()
				Wheel.apply_impulse(Vector2.ZERO, look_vector*_stored_charge*charge_multiplier)
				increase_cooldown(Global.CHARGE)
				_stored_charge = 0
				$Pointer/ChargeBar.visible = false


func control_overload():
	if Input.is_action_pressed("overload"):
		if !overload_active:
			return
		
		$sfx_goodoverload.play()
		overload_active = false
		CooldownManager.restore_everything()
		var new = explosion.instance()
		add_child(new)
		move_child(new, get_child_count()-1)
		randomize()
		new.global_position = Wheel.position + Vector2((randi() % 4) - 2, (randi() % 4) - 2)
		UI.activate_overload()


func _on_Wheel_on_collision(collision_normal):
	if _bouncy and not CooldownManager.get_overload(Global.BOUNCE):
		$sfx_bounce.play()
		var bounce_direction = collision_normal.normalized()
		var velocity_projection = last_velocity.dot(-bounce_direction)
		if velocity_projection > 0:
			last_velocity -= last_velocity.project(-bounce_direction)
			Wheel.linear_velocity = last_velocity + bounce_direction * min(1000, velocity_projection * 1.3)


func increase_cooldown(type):
	if !deactivation_enabled:
		return
	
	CooldownManager.increase_cooldown(type)


func _on_CooldownManager_overloaded(type):
	$sfx_overload.play()
	if type == Global.BOUNCE:
		set_bouncy(false)
	elif type == Global.HOOK:
		set_hook(false)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "TeleportBegin":
		Wheel.global_position = _teleport_pos
		$AnimationPlayer.play("TeleportEnd")


func _on_Timer_timeout():
	if _bouncy:
		increase_cooldown(Global.BOUNCE)


func set_left_limit(limit):
	$Wheel/Camera2D.limit_left = limit

func set_right_limit(limit):
	$Wheel/Camera2D.limit_right = limit
