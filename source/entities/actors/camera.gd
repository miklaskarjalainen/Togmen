extends Camera

onready var anim := $hand_anim
const SENSITIVITY = 0.2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	anim.play("bobbing")

func _physics_process(_delta):
	var motion := get_parent().motion as Vector3
	motion.y = 0
	anim.playback_speed = motion.length() / 7.5

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == 2: 
		rotation_degrees.x -= event.relative.y * SENSITIVITY
		rotation_degrees.y -= event.relative.x * SENSITIVITY
	if Input.is_action_just_pressed("ui_cancel"):
		var cur := int(Input.get_mouse_mode() != 2)
		Input.set_mouse_mode(2*cur)
