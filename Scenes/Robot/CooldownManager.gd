extends Node2D

export(NodePath) var UIPath
onready var UI = get_node(UIPath)

const min_value = 0
const max_value = 100

var cooldowns = {Global.HOOK:[0, false, 35], Global.ROCKET:[0, false, 20], 
					Global.BOUNCE:[0, false, 4], Global.ANTI:[0, false, 20], 
					Global.TELEPORT:[0, false, 70], Global.CHARGE:[0, false, 55]}

signal overloaded


func restore_everything():
	for i in cooldowns.keys():
		cooldowns[i][0] = min_value
		if cooldowns[i][1]: $sfx_cd_on.play()
		cooldowns[i][0] = min_value
		cooldowns[i][1] = false
		update_cooldown(i)

func increase_cooldown(type):
	cooldowns[type][0] += cooldowns[type][2]
	if cooldowns[type][0] >= max_value:
		cooldowns[type][0] = max_value
		cooldowns[type][1] = true
		emit_signal("overloaded", type)
	update_cooldown(type)


func _on_CooldownTimer_timeout():
	for i in cooldowns.keys():
		cooldowns[i][0] -= 1
		if cooldowns[i][0] <= min_value:
			if cooldowns[i][1]: $sfx_cd_on.play()
			cooldowns[i][0] = min_value
			cooldowns[i][1] = false
		update_cooldown(i)


func update_cooldown(type):
	UI.set_cooldown(type, cooldowns[type][0])
	UI.set_overload(type, cooldowns[type][1])


func get_overload(type):
	if cooldowns[type][1] and type != Global.CHARGE:
		$sfx_cd_off.play()
		UI.shake_bar(type)
	return cooldowns[type][1]
