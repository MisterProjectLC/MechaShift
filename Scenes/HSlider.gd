extends HSlider

export var group = 'SFX'
var original_sfx = AudioServer.get_bus_volume_db(2)
var original_bgm = AudioServer.get_bus_volume_db(1)

func _ready():
	match group:
		'SFX': value = Global.sound_volume
		'BGM': value = Global.music_volume
	self.connect("value_changed", self, "_on_value_changed")


func _on_value_changed(value):
	match group:
		'SFX':
			print_debug((value) - max_value)
			AudioServer.set_bus_volume_db(2, value - max_value)
			Global.sound_volume = value
		'BGM':
			print_debug((value) - max_value)
			AudioServer.set_bus_volume_db(1, value - max_value)
			Global.music_volume = value
