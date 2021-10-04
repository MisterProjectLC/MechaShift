extends "res://Scenes/Menu.gd"

func _on_Play_button_up():
	play = true
	Global.should_advance_stage = false
	Transitions.play("CloseFromLeft")
