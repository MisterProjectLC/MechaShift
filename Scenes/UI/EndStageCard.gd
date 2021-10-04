extends Control

var time_max = 0
var time_shown = 0
var t = 0

signal next_pressed

func setup(time):
	$Title.text = "STAGE " + str(Global.current_stage)
	time_max = time


func _process(delta):
	t = min(t+delta, 1)
	time_shown = int(lerp(0, time_max, t))
	
	var time_str = ""
	if time_shown % 60 < 10:
		time_str = "0" + str(time_shown / 60) + ":0" + str(time_shown % 60)
	else:
		time_str = "0" + str(time_shown / 60) + ":" + str(time_shown % 60)
	
	$Time.text = "Time: " + str(time_str)
	


func _on_Next_button_up():
	emit_signal('next_pressed')
