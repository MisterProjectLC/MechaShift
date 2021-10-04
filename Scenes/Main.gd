extends Node2D

var time = 0
var expecting_transition = false

var stages = [
			{"scene":preload("res://Scenes/Stages/Stage0.tscn")},
			{"scene":preload("res://Scenes/Stages/Stage1.tscn")},
			{"scene":preload("res://Scenes/Stages/Stage2.tscn")},
			{"scene":preload("res://Scenes/Stages/Stage3.tscn")}
			]

func _ready():
	get_tree().paused = false
	if !Transitions.is_connected("transition_finished", self, "transition_finished"): 
		Transitions.connect("transition_finished", self, "transition_finished")
	time = 0
	open_scene()


func _process(delta):
	if Input.is_action_pressed("reload"):
		Global.should_advance_stage = true
		run_transition()


func _on_Timer_timeout():
	time += 1
	$CanvasLayer/UI.set_timer(time)


func set_night():
	$BackgroundCanvas/TextureRect.texture = preload("res://Assets/Art/Misc/Fundo2.png")
	$BackgroundCanvas/TextureRect2.modulate = Color(1, 1, 1, 0.5)


func open_scene():
	var current_scene = stages[Global.current_stage]["scene"].instance()
	add_child(current_scene)
	move_child(current_scene, 0)
	current_scene.position = Vector2.ZERO
	current_scene.setup($Robot)
	current_scene.connect("stage_ended", self, "stage_ended")


func stage_ended():
	Global.current_stage += 1
	get_tree().paused = true
	if Global.current_stage >= len(stages):
		$AnimationPlayer.play("RollCredits")
	else:
		run_transition()


func transition_finished(anim_name):
	if anim_name == "CloseFromLeft" and visible and expecting_transition:
		expecting_transition = false
		if Global.should_advance_stage:
			Global.should_advance_stage = false
			get_tree().reload_current_scene()
		else:
			Global.should_advance_stage = true
			$CanvasLayer/EndStage.setup(time)
			$CanvasLayer/EndStage.visible = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "RollCredits":
		get_tree().change_scene("res://Scenes/MainMenu.tscn")


func _on_EndStage_next_pressed():
	run_transition()


func run_transition():
	expecting_transition = true
	Transitions.play("CloseFromLeft")
