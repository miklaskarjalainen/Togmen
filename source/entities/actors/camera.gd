extends Camera

export var SENSITIVITY  := 0.15
export var NORMAL_FOV   := 70
export var SCOPED_FOV   := 30
export var CAMERA_CLAMP := 80

onready var player := get_parent().get_parent()

func _ready():
	if !get_parent().is_network_master():
		queue_free()
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta:float):
	# Grap / Release mouse cursor #
	if Input.is_action_just_pressed("ui_cancel"): 
		var cur := int(Input.get_mouse_mode() != 2)
		Input.set_mouse_mode(2*cur)
	
	SENSITIVITY = GameSettings.get_value("sensitivity", SENSITIVITY) # Get sensitivity
	_handle_weapon_scoping()

func _handle_weapon_scoping():
	var is_scoping:int = player.get_hand().get_weapon().is_scoping()
	if is_scoping:    # Is scoping
		fov = SCOPED_FOV
		return
	fov = NORMAL_FOV

func _input(event):
	# Mouse look #
	if event is InputEventMouseMotion and Input.get_mouse_mode() == 2: 
		var is_scoping:bool = player.get_hand().get_weapon().is_scoping()
		var new_sens = SENSITIVITY
		if is_scoping:
			new_sens *= 0.6
		
		get_parent().rotation_degrees.x -= event.relative.y * new_sens
		get_parent().rotation_degrees.y -= event.relative.x * new_sens
		get_parent().rotation_degrees.x  = clamp(get_parent().rotation_degrees.x, -CAMERA_CLAMP, CAMERA_CLAMP)
	
