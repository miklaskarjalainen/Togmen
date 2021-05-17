extends Spatial

signal on_map_load(map)

func _ready():
	# Load Map #
	var map_scene = load(GameSettings.match_settings["map"])
	var instance = map_scene.instance()
	add_child(instance)
	emit_signal("on_map_load", instance)
