extends "res://Scenes/Robot/Projectile.gd"

export(PackedScene) var explosion

func _on_Rocket_body_entered(_body):
	call_deferred("spawn_explosion")


func spawn_explosion():
	var new = explosion.instance()
	get_parent().add_child(new)
	get_parent().move_child(new, get_parent().get_child_count()-1)
	new.global_position = global_position
	queue_free()
