extends Spatial

# Todo: add swing
export  var player_path:NodePath
export  var raycast_path:NodePath

onready var player  = get_node(player_path)
onready var raycast = get_node(raycast_path)
onready var bullet_impact  = preload("res://source/particles/bullet_impact.tscn")
onready var blood_particle = preload("res://source/particles/blood_particle.tscn")
onready var weapons = get_children()

var current_weapon  := 0
var previous_weapon := 0

func _ready():
	if !is_network_master():
		set_process(false)
		set_physics_process(false)

func _physics_process(_delta:float):
	Debug.add_line("fire rate", get_weapon().fire_rate_counter)
	
	_handle_weapon_switching()
	_handle_shooting()

func _handle_weapon_switching():
	if Input.is_action_just_pressed("web_1"):
		_switch_weapon(0)
	if Input.is_action_just_pressed("web_2"):
		_switch_weapon(1)
	if Input.is_action_just_pressed("web_3"):
		_switch_weapon(2)
	if Input.is_action_just_pressed("web_4"):
		_switch_weapon(3)
	
	if Input.is_action_just_pressed("quick_switch"):
		_switch_weapon(previous_weapon)

func _handle_shooting():
	if Input.is_action_just_pressed("shoot"):
		_shoot()
	if Input.is_action_pressed("shoot") and get_weapon().is_auto():
		_shoot()

func _shoot():
	# Returns false if there's something preventing from shooting like,
	# firerate, reloading, pickup animation
	if !get_weapon().shoot():
		return
	
	# Set the raycast to the correct length
	var max_length:int       = get_weapon().get_max_range()
	raycast.rotation_degrees = get_weapon().get_recoil()
	raycast.cast_to          = Vector3(0,0, -max_length)
	raycast.force_raycast_update()
	
	# Get the object we hit
	if !raycast.is_colliding():
		return
	var target = raycast.get_collider()
	
	var bullet_distance = (raycast.global_transform.origin - raycast.get_collision_point()).length()
	var base_bullet_damage   = get_weapon().get_damage(bullet_distance)
	print("Bullet travel distance: ", bullet_distance)
	print("Would be damage: ", base_bullet_damage)
	
	# We hit the player?
	if not target is BodyPart:
		# Creates a bullet impact
		create_bullet_impact(raycast.get_collision_point())
		return
	
	# More damage if headshot, or less if hit legs
	var bullet_damage:int = target.get_multiplier() * base_bullet_damage
	var peer              = target.get_peer()
	var peer_id:int       = target.get_peer_id()
	
	# Feed back #
	create_blood(raycast.get_collision_point())
	Gui.hitmark_play()      # Gives feed back to the player
	
	print("Total Damage: ", bullet_damage)
	peer.rpc_id(peer_id, "_damage", bullet_damage, get_weapon().name)

puppet func create_bullet_impact(_location:Vector3):
	if is_network_master():
		rpc_unreliable("create_bullet_impact", _location)
	
	var instance = bullet_impact.instance()
	player.add_child(instance)
	instance.set_as_toplevel(true)
	instance.translation = _location
	instance.look_at(player.transform.origin, Vector3.UP)

puppet func create_blood(_location:Vector3):
	if is_network_master():
		rpc_unreliable("create_blood", _location)
	
	var instance = blood_particle.instance()
	player.add_child(instance)
	instance.set_as_toplevel(true)
	instance.translation = _location

puppet func _switch_weapon(_weapon:int):
	# Same weapon
	if _weapon == current_weapon:
		return
	
	# Update peer to have the same weapon
	if is_network_master():
		rpc("_switch_weapon", _weapon)
		previous_weapon = current_weapon
	
	current_weapon = _weapon
	
	# Hide all weapons, then make the new one visible
	for child in get_children():
		child.visible = false
	get_weapon().visible = true
	get_weapon()._play_anim("show")

func get_weapon():
	return get_children()[current_weapon]
