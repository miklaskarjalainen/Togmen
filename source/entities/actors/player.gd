extends Actor

const ACCEL_SPD     := 120
const AIR_ACCEL_SPD := 40
const JUMP_STR      := 12
const JUMP_MOV_BOOST:= 0.4 # Also known as bhopping
const GRAVITY       := 24

onready var camera     := $camera
onready var jump_timer := $jump_timer
onready var player_anim = get_node("player_model/AnimationPlayer")

var peer_name       := ""        # "nickname"
var motion          := Vector3() # current movement motion
var move_spd        := 15.0        # maximum allowed movement speed, changes with different weapons

var kill_count      := 0         # how many kills
var death_count     := 0         # how many times have died
var killstreak      := 0         # how many peers killed in a row without dying

func _ready():
	Gui.register_peer(self) # Adds this node to the scoreboard
	
	if is_network_master():
		$player_model.visible = false
		$hitbox.queue_free()
		peer_name = Net.master_name
		Gui.set_player(self) # Makes the gui show this players health and ammo

func _physics_process(delta:float):
	if is_network_master(): # This is in player's control
		_do_player_movement(delta)
		
		_update_name(peer_name)
		_update_position(translation, camera.rotation, rotation, motion)
		_update_stats(kill_count, death_count, killstreak)
		
		if Input.is_action_just_pressed("suicide"):
			_respawn()
		if Input.is_action_just_pressed("hurt"):
			health -= 10
		if health <= 0:
			Gui.killed_by("", "suicide")
			_respawn()
	else:
		_do_player_animations()

func _do_player_animations():
	if motion.length() > 2:
		player_anim.play("run")
	else:
		player_anim.stop(true)
		player_anim.play("idle")

func _do_player_movement(delta:float):
	# Controlling #
	var direction := Vector3()
	if Input.is_action_pressed("forwards"):
		direction -= global_transform.basis.z
	if Input.is_action_pressed("backwards"):
		direction += global_transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= global_transform.basis.x
	if Input.is_action_pressed("right"):
		direction += global_transform.basis.x
	
	# If grounded acceleration / de-acceleration
	if is_on_floor():
		motion += direction.normalized() * ACCEL_SPD * delta
		motion.x = lerp(motion.x, 0.0, 0.1)
		motion.z = lerp(motion.z, 0.0, 0.1)
	else: # Air acceleration and no de-accleretation
		motion += direction.normalized() * AIR_ACCEL_SPD * delta
	
	# Speedcap
	var hor_motion := motion
	hor_motion.y = 0 # dont take y in count
	if hor_motion.length() > move_spd: 
		motion.x = (hor_motion.normalized() * move_spd).x
		motion.z = (hor_motion.normalized() * move_spd).z
	elif hor_motion.length() < 0.8 and direction == Vector3() and is_on_floor(): # Rounds speeds of 0.1231 to 0
		motion.x = 0
		motion.z = 0
	
	# Jumping #
	if Input.is_action_just_pressed("jump"):
		jump_timer.start()
	
	# Bhopping, small speed bost if doing accurate jumps #
	if is_on_floor() and jump_timer.is_stopped():
		move_spd = get_hand().get_weapon().get_mov_speed()
	if !jump_timer.is_stopped() and is_on_floor():
		motion.y += JUMP_STR
		move_spd += JUMP_MOV_BOOST
	
	# Gravity #
	motion.y -= GRAVITY * delta;
	
	Debug.add_line("speed", hor_motion.length())
	Debug.add_line("is_grounded", is_on_floor())
	
	motion = move_and_slide(motion, Vector3.UP, true, 4)

func _respawn():
	# Full heal
	health = 100
	
	# Reload all guns
	for gun in get_hand().get_children():
		if gun is Weapon: # There're also particles :/
			gun.reload(true)
	killstreak  = 0
	death_count += 1
	
	# Respawn
	global_transform = get_parent().get_spawn()

# Networking #
puppet func _update_name(_peer_name:String):
	if is_network_master():
		rpc("_update_name", peer_name)
	peer_name = _peer_name

puppet func _update_position(_translation:Vector3, _xrotation:Vector3, _yrotation:Vector3, _motion:Vector3):
	if is_network_master():
		rpc_unreliable("_update_position", _translation, _xrotation, _yrotation, _motion)
		return
	motion          = _motion
	translation     = _translation
	rotation        = _yrotation
	camera.rotation = _xrotation

puppet func _update_stats(_kills:int, _deaths:int, _killstreak:int):
	if is_network_master():
		rpc("_update_stats", _kills, _deaths, _killstreak)
		return
	kill_count  = _kills
	death_count = _deaths
	killstreak  = _killstreak

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

master func _damage(dmg:int, var kill_type := ""):
	var by_who := get_tree().get_rpc_sender_id()
	
	health -= dmg
	print("damaged: %s, by: %s" % [dmg, by_who])
	
	if health <= 0:
		var killer_name = get_peer_name(by_who)
		
		Gui.killed_by(killer_name, kill_type)
		get_peer(by_who).rpc_id(by_who, "_eliminated_peer", get_unique_id(), kill_type)
		_ended_killstreak(killer_name, killstreak)
		
		_respawn()

master func _eliminated_peer(id:int, var kill_type := ""):
	kill_count += 1
	killstreak += 1
	_update_killstreak(killstreak)
	
	Gui.eliminated(get_peer_name(id), kill_type)

# Getters / Setters #
func get_peer(id:int):
	return GameWorld.get_peer(id)

func get_peer_name(var id := get_unique_id()) -> String:
	return GameWorld.get_peer_name(id)

func get_unique_id() -> int:
	return int(name)

func get_hand():
	return $camera/hand
