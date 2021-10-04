extends Node2D

var time = 20

var stages = [
			{"scene":preload("res://Scenes/Stages/Stage0.tscn")},
			{"scene":preload("res://Scenes/Stages/Stage1.tscn")}
			]

func _ready():
	Transitions.connect("transition_finished", self, "transition_finished")
	open_scene()

func _on_Timer_timeout():
	time -= 1
	if time <= 0:
		print_debug("GAME OVER")
	
	$CanvasLayer/UI.set_timer(time)

func open_scene():
	var current_scene = stages[Global.current_stage]["scene"].instance()
	add_child(current_scene)
	move_child(current_scene, 0)
	current_scene.position = Vector2.ZERO
	current_scene.setup($Robot)
	current_scene.connect("stage_ended", self, "stage_ended")


func stage_ended():
	Global.current_stage += 1
	if Global.current_stage >= len(stages):
		$AnimationPlayer.play("RollCredits")
	else:
		Transitions.play("CloseFromLeft")


func transition_finished(anim_name):
	get_tree().reload_current_scene()


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
