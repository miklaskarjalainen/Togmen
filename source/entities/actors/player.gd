extends KinematicBody

const MOV_SPEED   = 450
const JUMP_STR    = 8
const GRAVITY     = 8

onready var camera := $camera_lock/camera

func _physics_process(delta:float) -> void:
	if is_network_master(): # This is in player's control
		_do_player_movement(delta)
		_send_position()
	else:                   # Controller by an another player
		_update_peer(delta)

var motion := Vector3()
func _do_player_movement(delta:float) -> void:
	var forwards  = int(Input.is_action_pressed("ui_up"))
	var backwards = int(Input.is_action_pressed("ui_down"))
	var left      = int(Input.is_action_pressed("ui_left"))
	var right     = int(Input.is_action_pressed("ui_right"))
	var jump      = Input.is_action_just_pressed("ui_accept") and is_on_floor()
	
	var direction := Vector3()
	if forwards:
		direction -= camera.global_transform.basis.z
	if backwards:
		direction += camera.global_transform.basis.z
	if left:
		direction -= camera.global_transform.basis.x
	if right:
		direction += camera.global_transform.basis.x
	direction = direction.normalized() * MOV_SPEED * delta
	motion.x = direction.x
	motion.z = direction.z
	
	if jump:
		motion.y += JUMP_STR
	motion.y -= GRAVITY * delta;
	
	motion = move_and_slide(motion, Vector3.UP)

func _update_peer(delta:float) -> void:
	pass

# Networking #
remote func _update_info(_translation:Vector3, _rotation:Vector3):
	translation            = _translation
	$camera_lock.rotation  = _rotation

remote func _send_position():
	rpc_unreliable("_update_info", translation, $camera_lock.rotation)


# Getters / Setters #

# todo add support for other's ids
func get_unique_id() -> int:
	return get_tree().get_network_unique_id()
