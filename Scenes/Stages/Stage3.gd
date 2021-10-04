extends "res://Scenes/Stages/Stage.gd"

export(PackedScene) var violet_enemy
var spawned = false
var bosses = 0

func _setup():
	get_parent().set_night()


func _on_EndFight_body_entered(body):
	if spawned:
		return
	
	player.camera_limit_speed = 0
	player.set_left_limit(26000)
	
	for spawn in $Spawns.get_children():
		var new = violet_enemy.instance()
		$Objects.add_child(new)
		$Objects.move_child(new, $Objects.get_child_count()-1)
		new.global_position = spawn.global_position
		new.connect('tree_existing', self, 'boss_destroyed')
		bosses += 1
	spawned = true

func boss_destroyed():
	bosses -= 1
	if bosses <= 0:
		emit_signal("stage_ended")
