extends "res://Scenes/Stages/Stage.gd"


func _setup():
	player.deactivation_enabled = false


func _on_Area2D_body_entered(body):
	pass # Replace with function body.


func _on_ActivateCooldowns_body_entered(body):
	player.deactivation_enabled = true
