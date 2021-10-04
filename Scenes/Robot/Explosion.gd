extends Area2D

export var explosion_force = 0

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()


func _on_Explosion_body_entered(body):
	var distance_to_body = body.position - position
	if body.is_in_group("Rocket"):
		body.spawn_explosion()
	elif !(body is TileMap):
		body.apply_impulse(Vector2.ZERO, explosion_force * distance_to_body.normalized())
