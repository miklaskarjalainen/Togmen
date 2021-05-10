extends NetObject

export(int)   var throw_force = 45
export(int)   var max_damage  = 115
export(float) var fuse_time   = 2.5 # seconds
export(Curve) var damage_falloff

onready var hitbox     = $hitbox
onready var particles  = $smoke
onready var max_length = ($hitbox/sphere.shape as SphereShape).radius

func _ready():
	particles.emitting = false
	particles.one_shot = true

func _physics_process(delta):
	if $grenade.visible == false:
		self.linear_velocity  = Vector3()
		self.angular_velocity = Vector3()
		if $smoke.emitting == false:
			queue_free()

func do_damage_to(body):
	if not body is Peer:
		return
	if body.is_network_master():
		return
	
	# Damage Calculation #
	var body_position = body.global_transform.origin
	body_position.y = 0
	
	var self_position = self.global_transform.origin
	self_position.y = 0
	
	var length = self_position.distance_to(body_position)
	var damage_multiplier:float = damage_falloff.interpolate(float(length/max_length))
	var damage = max_damage * damage_multiplier
	
	# Prints #
	print("Name: ", body.name)
	print("Length: ", length)
	print("Damage: ", damage)
	
	# Do Damage #
	body._damage(int(damage), "grenade")

func setup_grenade(camera:Camera):
	var towards:Vector3 = camera.get_node("grenade_dir").global_transform.origin
	var direction      := camera.global_transform.origin.direction_to(towards)
	 
	$fuse_time.wait_time    = fuse_time
	global_transform.origin = camera.global_transform.origin
	if is_network_master():
		self.linear_velocity         = direction * throw_force
	
	set_as_toplevel(true)
	$fuse_time.start()

puppet func handle_exploding(var position := global_transform.origin):
	# Visual #
	self.sleeping = true
	$smoke.emitting = true
	$grenade.visible = false
	
	# Damage #
	if !is_network_master():
		global_transform.origin = position
		return
	rpc("handle_exploding", position)
	for body in $hitbox.get_overlapping_bodies():
		do_damage_to(body)

# Signals #
func _on_explode_timeout():
	handle_exploding()
