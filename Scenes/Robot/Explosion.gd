extends Area2D

export var explosion_force = 0

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


func _on_Explosion_body_entered(body):
	var distance_to_body = body.position - position
	body.apply_impulse(Vector2.ZERO, explosion_force *
		(30 - distance_to_body.length()) * distance_to_body.normalized())
