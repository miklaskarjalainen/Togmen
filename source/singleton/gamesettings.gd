extends Node

const SETTINGS_PATH = "res://settings.ini"
var   config := ConfigFile.new()

func _ready():
	load_settings()

func _physics_process(_delta):
	if Input.is_action_just_pressed("reload_settings"):
		load_settings()

func load_settings():
	# If settings.ini doesn't exist, create one
	var directory = Directory.new()
	if !directory.file_exists(SETTINGS_PATH):
		print("Created new settings.ini")
		config.save(SETTINGS_PATH)
	
	# Load the settings.ini file
	var err = config.load(SETTINGS_PATH)
	if err != OK:
		push_warning("Error loading settings: %s" % err)
	
	# Map all the keys into actions
	for action_name in config.get_section_keys("actions"):
		_add_action(action_name)
	
	# Set some settings
	Engine.target_fps = get_value("target_fps", 144)
	OS.vsync_enabled  = get_value("vsync", false)
	OS.window_fullscreen = get_value("fullscreen", true)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_IGNORE, get_value("resolution", Vector2(1280,720))) # Loads the resolution

func _add_action(action:String):
	# Clear the action if there's already something
	if InputMap.has_action(action):
		InputMap.action_erase_events(action)
	else:
		InputMap.add_action(action)
	
	var inputs = config.get_value("actions", action)
	
	# Handles an array of inputs e.g forwards = ["W", "UpArrow"]
	if   typeof(inputs) == TYPE_ARRAY:
		for key in inputs:
			_add_key_to_action(action, key)
	
	# Handles an input e.g forwards = "W"
	elif typeof(inputs) == TYPE_STRING:
		_add_key_to_action(action, inputs)

# Adds a key to an action
func _add_key_to_action(action:String, key:String):
	var action_button     := InputEventKey.new()
	action_button.scancode = OS.find_scancode_from_string(key) #read the scancode from the ini
	InputMap.action_add_event(action, action_button)
	print("Added action %s with button %s" % [action, key])

func get_value(key:String, default = null):
	if config.has_section_key("settings", key):  # if the key did exist
		return config.get_value("settings", key, default)
	config.set_value("settings", key, default)
	print("Added new entry %s to settings.ini" % key)
	return default

func _exit_tree():
	config.save(SETTINGS_PATH)
