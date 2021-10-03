extends Node2D

var player

signal stage_ended

func setup(player):
	self.player = player
	_setup()

func _setup():
	pass

func _on_EndStage_body_entered(body):
	emit_signal("stage_ended")
