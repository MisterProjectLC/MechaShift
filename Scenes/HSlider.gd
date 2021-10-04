extends HSlider

export var group = 'SFX'
var original_sfx = AudioServer.get_bus_volume_db(2)
var original_bgm = AudioServer.get_bus_volume_db(1)

func _ready():
	self.connect("value_changed", self, "_on_value_changed")


func _on_value_changed(value):
	print_debug("miau")
	match group:
		'SFX':
			print_debug(value - max_value) 
			AudioServer.set_bus_volume_db(2, value - max_value)
		'BGM':
			print_debug(value - max_value)
			AudioServer.set_bus_volume_db(1, value - max_value)
