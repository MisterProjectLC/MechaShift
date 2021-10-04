extends "res://Scenes/Menu.gd"


func toggle_pause():
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		$AnimationPlayer.play("Blackout")
	else:
		$AnimationPlayer.play_backwards("Blackout")


func _on_Back_button_up():
	toggle_pause()


func _on_Menu_button_up():
	Transitions.play("CloseFromLeft")


func transition_finished(anim_name):
	if anim_name == "CloseFromLeft" and visible:
		get_tree().paused = false
		get_tree().change_scene("res://Scenes/MainMenu.tscn")
