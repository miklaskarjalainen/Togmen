extends Control

func _get_resolution(idx:int) -> Vector2:
	match idx:
		0:
			return Vector2(1280,1024)
		1:
			return Vector2(1280,720)
		2:
			return Vector2(1920,1080)
		3:
			return Vector2(2560,1440)
		4:
			return Vector2(3840,2160)
		_:
			return Vector2(1280,720)

func _get_res_idx(resolution:Vector2) -> int:
	match resolution:
		Vector2(1280,1024):
			return 0
		Vector2(1280,720):
			return 1
		Vector2(1920,1080):
			return 2
		Vector2(2560,1440):
			return 3
		Vector2(3840,2160):
			return 4
		_:
			return 0

func _ready():
	var current_res = GameSettings.get_value("resolution", Vector2(1280,720))
	print("Current RES: ", current_res)
	
	$resolution_option.selected = _get_res_idx(current_res)
	$fullscreen.pressed = GameSettings.get_value("fullscreen", true)
	
	_on_apply_pressed()

func _on_apply_pressed():
	# Resolution #
	var new_resolution = _get_resolution($resolution_option.selected)
	GameSettings.set_value("resolution", new_resolution)
	GameSettings.set_resolution(new_resolution)
	
	# Fullscreen #
	OS.window_fullscreen = $fullscreen.pressed
	GameSettings.set_value("fullscreen", $fullscreen.pressed)
	
	# Others #
	Engine.target_fps = GameSettings.get_value("target_fps", 144)
	OS.vsync_enabled  = GameSettings.get_value("vsync", false)
