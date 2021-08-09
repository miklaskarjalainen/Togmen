extends Control


signal on_pack_pressed


func _physics_process(delta:float):
	if $maps.get_selected_items().size() != 1:
		$host.disabled = true
	else:
		$host.disabled = false

func get_map_path(idx:int) -> String:
	match idx:
		0:
			return "res://source/worlds/marsic.tscn"
		1:
			return "res://source/worlds/alientus.tscn"
		_:
			return "res://source/worlds/marsic.tscn"

# Signals #

func _on_back_pressed():
	emit_signal("on_pack_pressed")

func _on_host_pressed():
	GameSettings.match_settings["map"]       = get_map_path($maps.get_selected_items()[0])
	GameSettings.match_settings["matchtime"] = $match_time.value
	print(str(GameSettings.match_settings))
	Net.create_server()
