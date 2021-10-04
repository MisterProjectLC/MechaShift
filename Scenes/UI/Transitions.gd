extends Control

signal transition_finished

func play(anim_name):
	$AnimationPlayer.play(anim_name)


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("transition_finished", anim_name)
	if anim_name == "CloseFromLeft":
		$AnimationPlayer.play("OpenFromRight")
