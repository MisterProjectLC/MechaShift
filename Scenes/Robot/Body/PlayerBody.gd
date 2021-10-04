extends Node2D

onready var robot = get_parent().get_parent()

func _process(_delta):
	if robot:
		_update_animation()


func _update_animation():
	var current_force = (robot.Wheel as RigidBody2D).angular_velocity
	if current_force > 0:
		scale.x = 1
		$AnimationPlayer.play("run")
	elif current_force < 0:
		scale.x = -1
		$AnimationPlayer.play("run")
	else:
		$AnimationPlayer.play("idle")


func play_animation(animation):
	$AnimationPlayer.play(animation)
