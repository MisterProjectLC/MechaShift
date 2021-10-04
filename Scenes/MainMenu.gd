extends "res://Scenes/Menu.gd"

var play_flicker = true

func _on_Play_button_up():
	if $Options.visible:
		$AnimationPlayer.play("StagesClose")
	else:
		if play_flicker:
			$AnimationPlayer.play("StagesOpen")
		else:
			$AnimationPlayer.play("StagesOpenNormal")
	play_flicker = false


func play(i):
	play = true
	if i != null:
		Global.current_stage = i
	Global.should_advance_stage = false
	Transitions.play("CloseFromLeft")


func _on_PhaseT_button_up():
	play(0)


func _on_Phase1_button_up():
	play(1)


func _on_Phase2_button_up():
	play(2)


func _on_Phase3_button_up():
	play(3)


func _on_CloseLevel_button_up():
	$AnimationPlayer.play("StagesClose")
