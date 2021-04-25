extends Actor

const MOV_SPEED   = 15
const JUMP_STR    = 12
const GRAVITY     = 24

onready var camera  := $camera_lock/camera

func _ready():
	if is_network_master():
		$body.visible = false

func _physics_process(delta:float):
	if is_network_master(): # This is in player's control
		_do_player_movement(delta)
		_send_position()
		
		if Input.is_action_just_pressed("suicide"):
			_respawn()
		if Input.is_action_just_pressed("hurt"):
			health -= 10
		
		if health <= 0:
			_respawn()

var motion := Vector3()
func _do_player_movement(delta:float):
	var direction := Vector3()
	if Input.is_action_pressed("forwards"):
		direction -= camera.global_transform.basis.z
	if Input.is_action_pressed("backwards"):
		direction += camera.global_transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= camera.global_transform.basis.x
	if Input.is_action_pressed("right"):
		direction += camera.global_transform.basis.x
	direction = direction.normalized() * MOV_SPEED
	motion.x = direction.x
	motion.z = direction.z
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		motion.y += JUMP_STR

	motion.y -= GRAVITY * delta;
	
	Debug.add_line("speed", motion.length())
	Debug.add_line("is_grounded", is_on_floor())
	
	motion.y = move_and_slide(motion, Vector3.UP, true, 4).y

# Networking #
puppet func _update_info(_translation:Vector3, _rotation:Vector3):
	translation            = _translation
	$camera_lock.rotation  = _rotation

master func _damage(dmg:int):
	var by_who := get_tree().get_rpc_sender_id()
	health -= dmg
	print("damaged: %s, by: %s" % [dmg, by_who])
	
	if health <= 0:
		print("got killed by: ", by_who)
		_respawn()

func _send_position():
	rpc_unreliable("_update_info", translation, $camera_lock.rotation)

# Getters / Setters #

func _respawn():
	health = 100
	global_transform = get_parent().get_spawn()

func get_unique_id() -> int:
	return int(name)
