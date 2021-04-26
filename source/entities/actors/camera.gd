extends Camera


const CAMERA_CLAMP := 80

onready var player := get_parent().get_parent()
var sensitivity    := 0.2

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
	
	sensitivity = GameSettings.get_value("sensitivity", 0.2) # Get sensitivity
	_handle_weapon_scoping()

var is_scoping := false
func _handle_weapon_scoping():
	var can_scope:int = player.get_hand().get_weapon().can_scope()
	
	# Scope only on weapons that can scope
	if Input.is_action_just_pressed("scope"):
		if can_scope:
			is_scoping = not is_scoping
	
	if is_scoping:    # Is scoping
		if can_scope: # Current weapon can still scope
			fov = 30
			return
		is_scoping = false # Switched from a scoped weapon without scoping
	fov = 70

func _input(event):
	# Mouse look #
	if event is InputEventMouseMotion and Input.get_mouse_mode() == 2: 
		get_parent().rotation_degrees.x -= event.relative.y * sensitivity
		get_parent().rotation_degrees.y -= event.relative.x * sensitivity
		get_parent().rotation_degrees.x  = clamp(get_parent().rotation_degrees.x, -CAMERA_CLAMP, CAMERA_CLAMP)
	
