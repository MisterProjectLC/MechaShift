extends "res://Scenes/Robot/Projectile.gd"

signal hook_attached

func _on_Hook_body_entered(body):
	applied_force = Vector2.ZERO
	linear_velocity = Vector2.ZERO
	mass = 1000
	gravity_scale = 0
	emit_signal("hook_attached")
