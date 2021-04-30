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

onready var player = get_node("../../../")
onready var anim = $AnimationPlayer
onready var cur_ammo:int = max_ammo
var is_scoping          := false
var fire_rate_counter   := 0.0

func _ready():
	anim.connect("animation_finished", self, "_on_animation_finish")

func _physics_process(delta:float):
	if fire_rate_counter > 0.0:
		fire_rate_counter -= delta
	
	if !anim.is_playing():
		_play_anim("idle")
	
	# Reload #
	if Input.is_action_just_pressed("reload_gun"):
		reload()
	
	# Scope only on weapons that can scope
	if Input.is_action_just_pressed("scope"):
		if can_scope:
			is_scoping = not is_scoping
	if !visible:
		is_scoping = false

# Methods #
func reload(var fast := false):
	if max_ammo == 0:
		return
	if cur_ammo >= max_ammo:
		return
	if is_reloading():
		return
	if fast: #Reloading without the animation
		_on_animation_finish("reload")
		return
	is_scoping = false
	_play_anim("reload")

# Returns true if can shoot
func shoot() -> bool:
	# Checks #
	if fire_rate_counter > 0:
		return false
	if anim.current_animation == "show":
		return false
	if anim.current_animation == "reload":
		return false
	if cur_ammo <= 0 and max_ammo != 0:
		return false
	
	# Shooting #
	fire_rate_counter = fire_rate
	cur_ammo -= 1
	_play_anim("attack1")
	
	return true

puppet func _play_anim(anim_name:String):
	if is_network_master(): # Gun animations shows on other's games aswell
		rpc("_play_anim", anim_name)
	if anim.has_animation(anim_name):
		anim.stop()
		anim.play(anim_name)
		return
	push_warning("Weapon had no animation: " + anim_name)

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
	if !visible:
		return
	
	if anim_name == "reload":
		cur_ammo = max_ammo
	# Auto Reload
	elif anim_name == "attack1" and cur_ammo == 0: 
		reload()
