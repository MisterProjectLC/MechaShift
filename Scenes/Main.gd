extends Node2D

var time = 20

var stages = [{"scene":preload("res://Scenes/Stages/Stage0.tscn"), "":""}]

func _ready():
	var new_scene = stages[0]["scene"].instance()
	add_child(new_scene)
	move_child(new_scene, 0)
	new_scene.position = Vector2.ZERO
	new_scene.setup($Robot)

func _on_Timer_timeout():
	time -= 1
	if time <= 0:
		print_debug("GAME OVER")
	
	$CanvasLayer/UI.set_timer(time)
