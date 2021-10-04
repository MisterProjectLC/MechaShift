extends "res://Scenes/Stages/Stage.gd"

export(PackedScene) var violet_enemy
var spawned = false
var bosses = 0

func _setup():
	get_parent().set_night()


func _on_EndFight_body_entered(body):
	if spawned:
		return
	
	$Tween.interpolate_method($bgm, "set_volume_db",
			$bgm.get_volume_db(), -60, 5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	player.camera_limit_speed = 0
	player.set_left_limit(26000)
	
	for spawn in $Spawns.get_children():
		var new = violet_enemy.instance()
		$Objects.add_child(new)
		$Objects.move_child(new, $Objects.get_child_count()-1)
		new.global_position = spawn.global_position
		new.connect('tree_exiting', self, 'boss_destroyed')
		bosses += 1
	spawned = true

func boss_destroyed():
	bosses -= 1
	if bosses <= 0:
		$battle.stop()
		emit_signal("stage_ended")


func _on_Tween_tween_completed(object, key):
	$bgm.stop()
	$battle.play()
