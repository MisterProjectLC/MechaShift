extends "res://Scenes/Stages/Stage.gd"


func _setup():
	player.deactivation_enabled = false
	player.camera_limit_speed = 0
	player.set_right_limit(29824)


func _on_ActivateCooldowns_body_entered(_body):
	player.deactivation_enabled = true
