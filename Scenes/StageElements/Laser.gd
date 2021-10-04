extends Node2D

var t = 0

func _ready():
	$EmitterA/Laser/CollisionShape2D.get_shape().extents = Vector2(($EmitterB.position.x - $EmitterA.position.x)/2, 24)

func _process(delta):
	t += delta
	$EmitterA.linear_velocity = Vector2(0, cos(t)*20)
	$EmitterB.linear_velocity = Vector2(0, cos(t)*20)


func _on_Timer_timeout():
	$EmitterA/Laser/CollisionShape2D.disabled = false
	$EmitterA/Laser/Sprite.visible = true
	$Deactivate.start()


func _on_Deactivate_timeout():
	$EmitterA/Laser/CollisionShape2D.disabled = true
	$EmitterA/Laser/Sprite.visible = false


func _on_Laser_body_entered(body):
	if body.is_in_group("Player"):
		# cursed but gets the job the done. It's a jam, after all
		body.get_parent().increase_cooldown(Global.HOOK)
		body.get_parent().increase_cooldown(Global.ROCKET)
		body.get_parent().increase_cooldown(Global.BOUNCE)
		body.get_parent().increase_cooldown(Global.ANTI)
		body.get_parent().increase_cooldown(Global.TELEPORT)
		body.get_parent().increase_cooldown(Global.CHARGE)
