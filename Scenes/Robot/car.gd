extends RigidBody2D

export var SPEED = 10

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		$r_wheel.angular_velocity = SPEED
		$l_wheel.angular_velocity = SPEED

	elif Input.is_action_pressed("ui_left"):
		$r_wheel.angular_velocity = -SPEED
		$l_wheel.angular_velocity = -SPEED
