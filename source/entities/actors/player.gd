extends Actor
class_name Peer

const ACCEL_SPD     := 120
const AIR_ACCEL_SPD := 40
const JUMP_STR      := 12
const JUMP_MOV_BOOST:= 0.4 # Also known as bhopping
const GRAVITY       := 24

onready var camera     := $camera
onready var jump_timer := $jump_timer
onready var player_anim:= get_node("player_model/AnimationPlayer")

var peer_data := {
	"id":0,
	"peer_name":"",
	"skin":0,
}

var killer_path:NodePath = ""      # Reference to the node who killed us

var motion          := Vector3() # current movement motion
var move_spd        := 15.0      # maximum allowed movement speed, changes with different weapons
var is_crouching    := false

var kill_count      := 0         # how many kills
var death_count     := 0         # how many times have died
var killstreak      := 0         # how many peers killed in a row without dying

func _ready():
	GameWorld.current_gamestate = GameWorld.GameState.InGame
	Gui.register_peer(self) # Adds this node to the scoreboard
	
	if is_network_master():
		$player_model.hide()
		$hitbox.queue_free()
		Gui.set_player(self) # Makes the gui show this players health and ammo
		
		rpc("_register", peer_data)
	else:
		print("Requested peerinfo")
		rpc_id( self.get_unique_id() , "_request_register") # when this non master peer is ready ask peer info from the real player
		$player_model.hide_arms()

func _physics_process(delta:float):
	if is_network_master(): # This is in player's control
		_do_player_movement(delta)
		_do_death_camera(delta)
		
		_update_look(camera.rotation, rotation)
		_update_position(translation, motion, is_crouching)
		_update_stats(kill_count, death_count, killstreak, health)
		
		if Input.is_action_just_pressed("hurt"):
			health -= 10
		if health <= 0 and get_killer() == null:
			Gui.killed_by("", "suicide")
			_respawn()
	
	_do_player_animations()

func _do_player_animations():
	if player_anim == null:
		return
	if is_dead():
		return
	
	# Crouching #
	if is_crouching:
		if has_node("hitbox"):
			$hitbox/anim.play("crouch")
		$camera.translation.y = 0.856
	else:
		if has_node("hitbox"):
			$hitbox/anim.play("stand")
		$camera.translation.y = 1.425
	
	if is_network_master():
		return
	
	# Animations #
	if is_crouching:
		player_anim.play("crouch_run")
	else:
		if motion.length() > 2:
			player_anim.play("run")
		else:
			player_anim.play("idle")

func _do_player_movement(delta:float):
	# Controlling #
	var direction := Vector3()
	direction -= global_transform.basis.z * Input.get_action_strength("forwards")
	direction += global_transform.basis.z * Input.get_action_strength("backwards")
	direction -= global_transform.basis.x * Input.get_action_strength("left")
	direction += global_transform.basis.x * Input.get_action_strength("right")
	
	# If grounded acceleration / de-acceleration
	if is_grounded():
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
	elif hor_motion.length() < 1.4 and direction == Vector3() and is_grounded(): # Rounds speeds of 0.1231 to 0
		motion.x = 0
		motion.z = 0
	
	# Jumping #
	if Input.is_action_just_pressed("jump"):
		jump_timer.start()
	
	# Bhopping, small speed bost if doing accurate jumps #
	if is_grounded() and jump_timer.is_stopped():  # If grounded reset current max speed
		move_spd = get_hand().get_weapon().get_mov_speed() - (int(is_crouching) * 4)
	if !jump_timer.is_stopped() and is_grounded(): # If grounded and pressed space with in ~0.1s, jump
		motion.y = JUMP_STR
		move_spd += JUMP_MOV_BOOST
	
	# Crouching #
	is_crouching = Input.is_action_pressed("crouch")
	
	# Gravity #
	motion.y -= GRAVITY * delta
	
	Debug.add_line("speed", hor_motion.length())
	Debug.add_line("is_grounded", is_grounded())
	Debug.add_line("is_crouching", is_crouching)
	Debug.add_line("is_host", Net.is_host())
	
	motion = move_and_slide(motion, Vector3.UP, true, 4)

func _do_death_camera(delta:float):
	var killer = get_killer()
	if killer != null:
		var time        := 2
		var goto:Vector3 = killer.get_node("camera").global_transform.origin
		$camera.look_at(goto, Vector3.UP)
		$camera.global_transform.origin = $camera.global_transform.origin.linear_interpolate(goto, time * delta)

func _respawn():
	# Reset killer
	killer_path = ""
	
	# Full heal
	health = 100
	
	# Reload all guns
	for gun in get_hand().get_children():
		if gun is Weapon: # Do only for weapons
			gun.reload(true)
	killstreak  = 0
	death_count += 1
	
	# Respawn
	$camera.translation = Vector3()
	$camera.rotation    = Vector3()
	global_transform = get_parent().get_spawn()

# Networking #
puppet func _update_look(_xrotation:Vector3, _yrotation:Vector3):
	if is_network_master():
		rpc_unreliable("_update_look", _xrotation, _yrotation)
		return
	rotation        = _yrotation
	camera.rotation = _xrotation

puppet func _update_position(_translation:Vector3, _motion:Vector3, _crouching:bool):
	if is_network_master():
		rpc_unreliable("_update_position", _translation, _motion, _crouching)
		return
	is_crouching    = _crouching
	motion          = _motion
	translation     = _translation

puppet func _update_stats(_kills:int, _deaths:int, _killstreak:int, _health:int):
	if is_network_master():
		rpc("_update_stats", _kills, _deaths, _killstreak, _health)
		return
	kill_count  = _kills
	death_count = _deaths
	killstreak  = _killstreak
	health      = _health
	visible = true if health > 0 else false

puppet func _update_killstreak(_count:int):
	# This peer's killstreak got updated #
	
	if _count >= 5:
		if is_network_master():
			rpc("_update_killstreak", _count)  # Player, broadcast others about player's new killstreak
		Gui.show_killstreak(peer_data["peer_name"], _count) # If a peer show that someone else has a killstreak going

puppet func _ended_killstreak(_ender:String, _count:int):
	# This peer's killstreak was ended #
	
	if _count >= 5:
		if is_network_master(): 
			rpc("_ended_killstreak", _ender, _count)    # Player, broadcast others that your killstreak was ended
		Gui.ended_killstreak(_ender, peer_data["peer_name"], _count) # If a peer show that someone else's killstreak was ended

puppet func _register(dict:Dictionary):
	print("register, got: ", dict)
	peer_data = dict
	set_skin(peer_data["skin"])

master func _request_register():
	var id := get_tree().get_rpc_sender_id()
	print("gave info to: ", id, " which was ", peer_data)
	rpc_id(id, "_register", peer_data)

master func _damage(dmg:int, var kill_type := ""):
	if !is_network_master():
		rpc_id(get_unique_id(), "_damage", dmg, kill_type)
		return
	# This peer received damage from a peer #
	
	# Handle the damage #
	var by_who := get_tree().get_rpc_sender_id() # The peer's id who damaged the player
	health -= dmg
	print("damaged: %s, by: %s" % [dmg, by_who])
	
	if is_dead() and $respawn_timer.is_stopped(): # If the player died
		killer_path = get_peer(by_who).get_path()
		
		# Inform the peer who killed us, that they killed us #
		get_killer().rpc_id(by_who, "_eliminated_peer", get_unique_id(), kill_type)
		
		# If we had a killstreak bigger than 4, then tell who ended it #
		var killer_name = GameWorld.get_peer_name(by_who)
		_ended_killstreak(killer_name, killstreak) 
		
		# Show gui, also inform who killed the player # 
		Gui.killed_by(killer_name, kill_type)
		$respawn_timer.start() # after which the player respawns

master func _eliminated_peer(peer_id:int, var kill_type := ""):
	# The player has eliminated peer with the given id #
	var peer_name = GameWorld.get_peer_name(peer_id)
	
	# Update Stats #
	kill_count += 1
	killstreak += 1
	
	# If killstreak is bigger than 4, then it's broadcasted to all peers #
	_update_killstreak(killstreak)
	
	# Show the eliminated gui #
	Gui.eliminated(peer_name, kill_type)

# Getters / Setters #
func set_skin(idx:int):
	$player_model.call_deferred("set_skin", idx)

func is_grounded() -> bool:
	return is_on_floor() or $is_grounded.is_colliding()

func is_dead() -> bool:
	return health <= 0

func get_peer(id:int):
	return GameWorld.get_peer(id)

func get_killer():
	if killer_path == "":
		return null
	return get_node_or_null(killer_path)

func get_unique_id() -> int:
	# Gets this peer's id
	return int(name)

func get_hand():
	# Gets the node which holds all of the guns 
	return $camera/hand

# Signals #
func _on_respawn_timer_timeout():
	_respawn()
