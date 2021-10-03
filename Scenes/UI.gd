extends Control

onready var HookBar = $Background/Cooldowns/Column1/Hook
onready var RocketBar = $Background/Cooldowns/Column1/Rocket
onready var BounceBar = $Background/Cooldowns/Column2/Bounce
onready var AntiBar = $Background/Cooldowns/Column2/AntiGravity
onready var TeleportBar = $Background/Cooldowns/Column3/Teleport
onready var ChargeBar = $Background/Cooldowns/Column3/Charge

export(StyleBox) var cooldown
export(StyleBox) var overload

onready var Bars = {Global.HOOK:HookBar, Global.ROCKET:RocketBar, 
					Global.BOUNCE:BounceBar, Global.ANTI:AntiBar, 
					Global.TELEPORT:TeleportBar, Global.CHARGE:ChargeBar}


func set_cooldown(type, amount):
	Bars[type].value = amount


func set_overload(type, value):
	if value:
		Bars[type].set("custom_styles/fg", overload)
	else:
		Bars[type].set("custom_styles/fg", cooldown)
