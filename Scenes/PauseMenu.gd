extends "res://Scenes/Menu.gd"


func toggle_pause():
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		$AnimationPlayer.play("Blackout")
	else:
		$AnimationPlayer.play_backwards("Blackout")


func _on_Back_button_up():
	toggle_pause()
