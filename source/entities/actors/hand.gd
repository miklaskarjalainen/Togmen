extends Spatial

# Todo: add swing
export  var raycast_path:NodePath
export  var gui_path:NodePath

onready var raycast = get_node(raycast_path)
onready var gui     = get_node(gui_path)

var current_weapon

func _ready():
	_switch_weapon(0)
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
	var max_length:int = get_weapon().get_max_range()
	raycast.cast_to = Vector3(0,0, -max_length)
	raycast.force_raycast_update()
	
	# Get the object we hit
	var target = raycast.get_collider()
	if not target is Actor: # The object was not a player
		return
	gui.hitmark_play()      # Gives feed back to the player
	target.rpc_id(int(target.name), "_damage", get_weapon().get_damage())

puppet func _switch_weapon(web:int):
	if is_network_master():
		rpc("_switch_weapon", web)
	
	current_weapon = get_children()[web]
	
	# Hide all weapons, then make the new one visible
	for child in get_children():
		child.visible = false
	current_weapon.visible = true
	current_weapon._play_anim("show")

func get_weapon():
	if current_weapon == null:
		return get_children()[0]
	return current_weapon
