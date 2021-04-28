extends Actor

const JUMP_STR     = 12
const GRAVITY      = 24

onready var camera  := $camera

var peer_name       := ""
var motion          := Vector3()
var move_speed      := 15.0 # default if couldn't get one from a weapon
var killstreak      := 0

func _ready():
	if is_network_master():
		$body.visible = false
		peer_name = Net.master_name
		Gui.set_player(self)

func _physics_process(delta:float):
	if is_network_master(): # This is in player's control
		_do_player_movement(delta)
		_update_name(peer_name)
		_update_position(translation, $camera.rotation)
		_update_capsule_color(GameSettings.get_value("capsule_color", Color(1.0, 0.3, 0.3, 1.0)))
		
		if Input.is_action_just_pressed("suicide"):
			_respawn()
		if Input.is_action_just_pressed("hurt"):
			health -= 10
		if health <= 0:
			Gui.killed_by("", "suicide")
			_respawn()

func _do_player_movement(delta:float):
	move_speed = get_hand().get_weapon().get_mov_speed()
	
	# Controlling #
	var direction := Vector3()
	if Input.is_action_pressed("forwards"):
		direction -= camera.global_transform.basis.z
	if Input.is_action_pressed("backwards"):
		direction += camera.global_transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= camera.global_transform.basis.x
	if Input.is_action_pressed("right"):
		direction += camera.global_transform.basis.x
	direction = direction.normalized() * move_speed
	motion.x = direction.x
	motion.z = direction.z
	
	# Jumping #
	if Input.is_action_just_pressed("jump") and is_on_floor():
		motion.y += JUMP_STR
	
	# Gravity #
	motion.y -= GRAVITY * delta;
	
	Debug.add_line("speed", motion.length())
	Debug.add_line("is_grounded", is_on_floor())
	
	motion.y = move_and_slide(motion, Vector3.UP, true, 4).y

func _respawn():
	# Full heal
	health = 100
	
	# Reload all guns
	for gun in $camera_lock/hand.get_children():
		if gun is Weapon: # There're also particles :/
			gun.reload(true)
	killstreak = 0
	
	# Respawn
	global_transform = get_parent().get_spawn()

# Networking #
puppet func _update_name(_peer_name:String):
	if is_network_master():
		rpc("_update_name", peer_name)
	peer_name = _peer_name

puppet func _update_position(_translation:Vector3, _rotation:Vector3):
	if is_network_master():
		rpc_unreliable("_update_position", _translation, _rotation)
		return
	translation            = _translation
	$camera_lock.rotation  = _rotation

puppet func _update_capsule_color(_color:Color):
	if is_network_master():
		rpc_unreliable("_update_capsule_color", _color)
		return
	$body.material.albedo_color = _color

puppet func _update_killstreak(_count:int):	
	if _count >= 5:
		if is_network_master():
			rpc("_update_killstreak", _count)
		Gui.show_killstreak(peer_name, _count)

puppet func _ended_killstreak(_ender:String, _count:int):	
	if _count >= 5:
		if is_network_master():
			rpc("_ended_killstreak", _ender, _count)
		Gui.ended_killstreak(_ender, peer_name, _count)

master func _damage(dmg:int, var web_name := ""):
	var by_who := get_tree().get_rpc_sender_id()
	
	health -= dmg
	print("damaged: %s, by: %s" % [dmg, by_who])
	
	if health <= 0:
		var killer_name = get_peer_name(by_who)
		
		Gui.killed_by(killer_name, web_name)
		get_peer(by_who).rpc_id(by_who, "_eliminated_peer", get_unique_id(), web_name)
		_ended_killstreak(killer_name, killstreak)
		_respawn()

# this player eliminated the gived peer
master func _eliminated_peer(id:int, var web_name := ""):
	killstreak += 1
	_update_killstreak(killstreak)
	
	Gui.eliminated(get_peer_name(id), web_name)

# Getters / Setters #
func get_peer(id:int):
	return get_parent().get_node(str(id))

func get_peer_name(var id := get_unique_id()) -> String:
	return get_parent().get_peer_name(id)

func get_unique_id() -> int:
	return int(name)

func get_hand():
	return $camera/hand
