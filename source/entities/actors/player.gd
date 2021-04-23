extends KinematicBody
const MOV_SPEED   = 450
const JUMP_STR    = 8
const GRAVITY     = 8

onready var camera := $camera
var motion := Vector3()

func _physics_process(delta:float) -> void:
	var forwards  = int(Input.is_action_pressed("ui_up"))
	var backwards = int(Input.is_action_pressed("ui_down"))
	var left      = int(Input.is_action_pressed("ui_left"))
	var right     = int(Input.is_action_pressed("ui_right"))
	var jump      = Input.is_action_just_pressed("ui_accept") and is_on_floor()
	
	var direction := Vector3()
	if Input.is_action_pressed("ui_up"):
		direction -= camera.global_transform.basis.z
	if Input.is_action_pressed("ui_down"):
		direction += camera.global_transform.basis.z
	if Input.is_action_pressed("ui_left"):
		direction -= camera.global_transform.basis.x
	if Input.is_action_pressed("ui_right"):
		direction += camera.global_transform.basis.x
	direction = direction.normalized() * MOV_SPEED * delta
	motion.x = direction.x
	motion.z = direction.z
	
	if jump:
		motion.y += JUMP_STR
	motion.y -= GRAVITY * delta;
	
	motion = move_and_slide(motion, Vector3.UP)
