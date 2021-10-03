extends "res://Scenes/Stages/Stage.gd"


func _setup():
	player.deactivation_enabled = false



func _on_ActivateCooldowns_body_entered(_body):
	player.deactivation_enabled = true
