extends Spatial

# Todo: add swing
export  var player_path       :NodePath
export  var player_model_path :NodePath
export  var raycast_path      :NodePath
export  var grenade_dir_path  :NodePath
export  var viewmodel_fov := 0.5

onready var player       = get_node(player_path)
onready var player_model = get_node(player_model_path)
onready var raycast      = get_node(raycast_path)
onready var grenade_dir  = get_node(grenade_dir_path)

onready var bullet_impact := preload("res://source/particles/bullet_impact.tscn")
onready var blood_particle:= preload("res://source/particles/blood_particle.tscn")
onready var grenade       := preload("res://assets/weapons/grenade/grenade.tscn")
onready var weapons = get_children()

var current_weapon  := 0
var previous_weapon := 0

func _ready():
	set_network_master(int(player.name))
	
	if !is_network_master():
		set_process(false)
		set_physics_process(false)
		return
	translation.z -= viewmodel_fov

func _physics_process(_delta:float):
	Debug.add_line("fire rate", get_weapon().fire_rate_counter)
	Debug.add_line("recovery time", get_weapon().recovery_counter)
	
	_handle_hand_animations()
	_handle_weapon_switching()
	_handle_shooting()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			_switch_weapon(current_weapon+1)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			_switch_weapon(current_weapon-1)

func _handle_hand_animations():
	visible = false if player.is_dead() else true # Hide arms if the player is dead
	
	if !get_weapon().has_node("left_hand"):
		return
	
	var left_rotation = get_weapon().get_node("left_hand").rotation
	var right_rotation = get_weapon().get_node("right_hand").rotation
	player_model.get_node("left_hand").rotation = left_rotation
	player_model.get_node("right_hand").rotation = right_rotation

func _handle_weapon_switching():
	if player.is_dead():
		return
	
	if Input.is_action_just_pressed("web_1"):
		_switch_weapon(0)
	if Input.is_action_just_pressed("web_2"):
		_switch_weapon(1)
	if Input.is_action_just_pressed("web_3"):
		_switch_weapon(2)
	if Input.is_action_just_pressed("web_4"):
		_switch_weapon(3)
	
	if Input.is_action_just_pressed("next_web"):
		_switch_weapon(current_weapon+1)
	if Input.is_action_just_pressed("prev_web"):
		_switch_weapon(current_weapon-1)
	
	if Input.is_action_just_pressed("quick_switch"):
		_switch_weapon(previous_weapon)

func _handle_shooting():
	if player.is_dead():
		return
	
	if   Input.is_action_just_pressed("shoot"):
		_shoot()
	elif Input.is_action_pressed("shoot") and get_weapon().is_auto():
		_shoot()
	if Input.is_action_just_pressed("throw_grenade") and grenade_dir.get_child_count() == 0:
		_throw_grenade()

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
	print("Target Name: ", target.name)
	
	# We hit the player?
	if not target is BodyPart:
		# Creates a bullet impact
		create_bullet_impact(raycast.get_collision_point())
		return
	
	# More damage if headshot, or less if hit legs
	var bullet_damage:int = target.get_multiplier() * base_bullet_damage
	var peer              = target.get_peer()
	var peer_id:int       = target.get_peer_id()
	
	# If isn't alive 
	if peer.is_dead():
		return
	
	# Feed back #
	create_blood(raycast.get_collision_point())
	Gui.hitmark_play()    # Gives feed back to the player
	
	print("Total Damage: ", bullet_damage)
	
	var kill_type = get_weapon().name
	if target.name == "head":
		kill_type = "headshot"
	if get_weapon().can_scope() and !get_weapon().is_scoping():
		kill_type = "noscope"
	
	peer.rpc_id(peer_id, "_damage", bullet_damage, kill_type)

puppet func _throw_grenade():
	if is_network_master():
		rpc("_throw_grenade")
	var instance = grenade.instance()
	var direction:Vector3
	direction -= global_transform.basis.x
	
	grenade_dir.add_child(instance)
	instance.set_network_master(int(player.name))
	instance.setup_grenade(get_parent())

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
	# Keep the weapon id in pounds
	_weapon = clamp(_weapon, 0, get_child_count() - 1)
	
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
