extends Camera

export var PLAYER_PATH:NodePath
export var SENSITIVITY  := 0.15
export var NORMAL_FOV   := 70
export var SCOPED_FOV   := 30
export var CAMERA_CLAMP := 80

onready var player    := get_node(PLAYER_PATH)

func _ready():
	set_network_master(int(player.name))
	
	if is_network_master():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		current = false

func _physics_process(delta:float):
	if !is_network_master():
		return
	
	SENSITIVITY = GameSettings.get_value("sensitivity", SENSITIVITY) # Get sensitivity
	_handle_weapon_scoping()

func _handle_weapon_scoping():
	var is_scoping:int = player.get_hand().get_weapon().is_scoping()
	if is_scoping:    # Is scoping
		fov = SCOPED_FOV # Zoom
		player.get_hand().visible = false
		return
	player.get_hand().visible = true
	fov = NORMAL_FOV

func _input(event):
	
	# Mouse look #
	if event is InputEventMouseMotion and Input.get_mouse_mode() == 2:
		var is_scoping:bool = player.get_hand().get_weapon().is_scoping()
		var new_sens = SENSITIVITY
		if is_scoping:
			new_sens *= 0.4
		rotation_degrees.x -= event.relative.y * new_sens
		player.rotation_degrees.y -= event.relative.x * new_sens
		rotation_degrees.x  = clamp(rotation_degrees.x, -CAMERA_CLAMP, CAMERA_CLAMP)

