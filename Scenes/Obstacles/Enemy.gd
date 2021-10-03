extends Node2D

onready var Pointer = $Pointer
onready var Body = $Body

export(PackedScene) var rocket
export(PackedScene) var death_explosion
var player
var look_vector

export var rocket_velocity = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group('Player')[0]



func _physics_process(delta):
	look_vector = (player.global_position - global_position).normalized()
	Pointer.position = Body.position
	Pointer.rotation = atan2(look_vector.y, look_vector.x)


func _on_Timer_timeout():
	if !player:
		return
	
	var new = rocket.instance()
	get_parent().add_child(new)
	get_parent().move_child(new, get_parent().get_child_count()-1)
	new.global_position = Pointer.global_position
	new.shoot(look_vector*rocket_velocity)


func _on_Body_body_entered(body):
	if body.is_in_group("Wall"):
		var new = death_explosion.instance()
		get_parent().add_child(new)
		get_parent().move_child(new, get_parent().get_child_count()-1)
		new.global_position = Body.global_position
		queue_free()
