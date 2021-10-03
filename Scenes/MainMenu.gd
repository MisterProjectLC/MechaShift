extends "res://Scenes/Menu.gd"

func _on_Play_button_up():
	play = true
	$AnimationPlayer.play("Blackout")
