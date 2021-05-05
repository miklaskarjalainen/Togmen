extends Spatial
class_name Weapon

const SCOPE_MOV_PENALTY = 2.5 

export(int, 0, 250, 1)       var base_damage    = 14
export(int, 0, 300, 1)       var max_ammo       = 30 # 0 = unlimited
export(float, 0, 0.5, 0.01)  var damage_falloff = 0.0  # per 1 unit
export(float, 0, 1.2, 0.02)  var base_recoil    = 0.10
export(float, 0, 1.0, 0.02)  var inaccuracy     = 0.10
export(float, 0.01, 2, 0.01) var fire_rate      = 0.14  # seconds
export(bool)                 var is_auto        = false
export(bool)                 var can_scope      = false
export(int, 0, 256, 1)       var max_range      = 256
export(float, 1, 15, 0.5)    var mov_speed      = 15.0

export  var sfx_shoot   :AudioStream
export  var sfx_reload  :AudioStream
onready var sfx_scope   := preload("res://assets/sfx/scope.ogg")

onready var player       = get_node("../../../") # Needed to calculate the recoil
onready var anim         = $AnimationPlayer
onready var cur_ammo:int = max_ammo
var is_scoping          := false
var fire_rate_counter   := 0.0

func _ready():
	anim.connect("animation_finished", self, "_on_animation_finish")
	player.get_node("player_model").connect("on_skin_changed", self, "_init_handtextures")

func _physics_process(delta:float):
	# Counts down the firerate timer #
	if fire_rate_counter > 0.0:
		fire_rate_counter -= delta
	
	if !visible:           # Not current weapon
		is_scoping = false
		return
	
	if !anim.is_playing(): # Idle animation
		_play_anim("idle")
	
	_handle_reloading()
	_handle_scoping()

# Methods #

func reload(var fast := false):
	if max_ammo == 0: # Unlimited ammo (knife)
		return
	if fast:          # Reloading without the animation
		_on_animation_finish("fast_reload")
		return
	if cur_ammo >= max_ammo:
		return
	if is_reloading(): # Is already reloading
		return
	
	is_scoping = false
	_play_sfx("reload")
	_play_anim("reload")

func shoot() -> bool:
	# Returns true if can shoot
	
	# Checks #
	if fire_rate_counter > 0:
		return false
	if anim.current_animation == "show":
		return false
	if anim.current_animation == "reload":
		return false
	if cur_ammo <= 0 and max_ammo != 0:
		return false
	
	# Shoot Sound effect
	_play_sfx("shoot")
	
	# Shooting #
	fire_rate_counter = fire_rate
	cur_ammo -= 1
	_play_anim("attack1")
	
	return true

func _handle_reloading():
	# Reload #
	if Input.is_action_just_pressed("reload_gun"):
		reload()

func _handle_scoping():
	# Scope only on weapons that can scope
	if Input.is_action_just_pressed("scope"):
		if can_scope:
			_play_sfx("scope")
			is_scoping = not is_scoping

func _init_handtextures(material:Material):
	print("Init hand textures")
	if has_node("left_hand"):
		for child in $left_hand.get_children():
			if !child is MeshInstance: # A gun and not a hand
				 continue
			child.set_material_override(material)
		for child in $right_hand.get_children():
			if !child is MeshInstance: # A gun and not a hand
				 continue
			child.set_material_override(material)

puppet func _play_anim(anim_name:String):
	if is_network_master(): # Gun animations shows on other's games aswell
		rpc("_play_anim", anim_name)
	if anim.has_animation(anim_name):
		anim.stop()
		anim.play(anim_name)
		return
	push_warning("Weapon had no animation: " + anim_name)

puppet func _play_sfx(sfx_name:String):
	if is_network_master():
		rpc("_play_sfx", sfx_name)
	
	match sfx_name:
		"reload":
			if sfx_reload != null:
				var sfx_player = get_node("../../reload_sfx")
				sfx_player.stream = sfx_reload
				sfx_player.play(0.0)
		"shoot":
			if sfx_shoot != null:
				var sfx_player = get_node("../../shoot_sfx")
				sfx_player.stream = sfx_shoot
				sfx_player.play(0.0)
		"scope":
			if sfx_scope != null:
				var sfx_player = get_node("../../scope_sfx")
				sfx_player.stream = sfx_scope
				sfx_player.play(0.0)
		_:
			push_warning("Invalid gun sound effect")

# Getters / Setters #
func get_recoil() -> Vector3:
	var JUMP_MULTIPLAIER     = 8
	var MOVEMENT_MULTIPLAYER = 3
	var NOSCOPE_PENALTY      = 4
	
	var recoil        := rand_vector(-inaccuracy, inaccuracy)
	var motion:Vector3 = player.motion
	
	randomize()
	
	# Y Movement #
	if abs(motion.y) > 0.4:
		var jump_recoil = base_recoil * JUMP_MULTIPLAIER
		recoil += rand_vector(-jump_recoil, jump_recoil)
	motion.y = 0
	
	# X Movement #
	var mov_recoil = base_recoil * (motion.length()/8.0) * MOVEMENT_MULTIPLAYER
	recoil += rand_vector(-mov_recoil, mov_recoil)
	
	# No Scopes #
	if can_scope() and !is_scoping():
		recoil += rand_vector(-NOSCOPE_PENALTY, NOSCOPE_PENALTY)
	
	print("Recoil was", recoil)
	return recoil

func get_mov_speed() -> float:
	return mov_speed - (SCOPE_MOV_PENALTY * float(is_scoping))

func get_cur_ammo() -> int:
	return cur_ammo

func get_max_ammo() -> int:
	return max_ammo

func get_damage(var tar_range := 0) -> int:
	if tar_range >= max_range:
		return 0
	return int(base_damage - (tar_range * damage_falloff))

func get_max_range() -> int:
	return max_range

func is_auto() -> bool:
	return is_auto

func is_reloading() -> bool:
	if !anim.has_animation("reload"):
		return false
	return anim.current_animation == "reload"

func is_scoping() -> bool:
	return is_scoping

func can_scope() -> bool:
	return can_scope

func rand_vector(_min:float, _max:float) -> Vector3:
	return Vector3(rand_range(_min, _max), rand_range(_min, _max), rand_range(_min, _max))

# Signals #

func _on_animation_finish(anim_name:String):
	# Normal Reload
	if anim_name == "reload" and visible:
		cur_ammo = max_ammo
	
	# Fast Reload
	if anim_name == "fast_reload":
		cur_ammo = max_ammo
	
	# Auto Reload after out of ammo #
	elif anim_name == "attack1" and cur_ammo == 0: 
		reload()
