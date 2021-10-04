extends Control

export(NodePath) var HookBar
export(NodePath) var RocketBar
export(NodePath) var BounceBar
export(NodePath) var AntiBar
export(NodePath) var TeleportBar
export(NodePath) var ChargeBar

export(StyleBox) var cooldown
export(StyleBox) var overload

onready var Bars = {Global.HOOK:get_node(HookBar), Global.ROCKET:get_node(RocketBar),
					Global.BOUNCE:get_node(BounceBar), Global.ANTI:get_node(AntiBar),
					Global.TELEPORT:get_node(TeleportBar), Global.CHARGE:get_node(ChargeBar)}



func _process(_delta):
	if Input.is_action_just_pressed("toggle_controls"):
		$Controls.visible = !$Controls.visible
	
	if Input.is_action_just_pressed("ui_cancel"):
		$Pause/PauseMenu.toggle_pause()


func set_cooldown(type, amount):
	Bars[type].value = amount


func set_overload(type, value):
	if value:
		Bars[type].set("custom_styles/fg", overload)
	else:
		Bars[type].set("custom_styles/fg", cooldown)


func activate_overload():
	$Background/Coil.visible = false
	$Background/Head.modulate = Color("721C2F")


func set_timer(time: int):
	if time % 60 < 10:
		$Background/Time.text = "0" + str(time / 60) + ":0" + str(time % 60)
	else:
		$Background/Time.text = "0" + str(time / 60) + ":" + str(time % 60)


func set_blackout(level):
	$Blackout.color = Color($Blackout.color.r, $Blackout.color.g, $Blackout.color.b, level)
