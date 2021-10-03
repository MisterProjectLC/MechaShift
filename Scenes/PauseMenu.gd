extends "res://Scenes/Menu.gd"


func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused


func _on_Back_button_up():
	toggle_pause()
