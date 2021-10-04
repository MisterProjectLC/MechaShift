extends Node2D

var player

export var right_limit = 29824

signal stage_ended

func setup(player):
	self.player = player
	player.set_right_limit(right_limit)
	_setup()

func _setup():
	pass

func _on_EndStage_body_entered(_body):
	emit_signal("stage_ended")
