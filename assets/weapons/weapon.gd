extends Spatial
class_name Weapon

onready var anim = $AnimationPlayer

export(int, 0, 250, 1)       var base_damage = 14
export(int, 0, 300, 1)       var max_ammo = 30      # 0 = unlimited
export(int, 0, 32, 1)        var damage_falloff = 0 # per 1 unit
export(float, 0.01, 2, 0.01) var fire_rate   = 0.14 # seconds
export(bool)                 var is_auto     = false
export(int, 0, 256, 1)       var max_range   = 256

onready var cur_ammo:int = max_ammo
var fire_rate_counter := 0.0

func _ready():
	anim.connect("animation_finished", self, "_on_animation_finish")

func _physics_process(delta:float):
	if fire_rate_counter > 0.0:
		fire_rate_counter -= delta
	if !anim.is_playing():
		_play_anim("idle")
	if Input.is_action_just_pressed("reload_gun"):
		reload()

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


# Getters / Setters #
func get_cur_ammo() -> int:
	return cur_ammo

func get_max_ammo() -> int:
	return max_ammo

func get_damage(var tar_range := 0) -> int:
	if tar_range >= max_range:
		return 0
	return base_damage

func get_max_range() -> int:
	return max_range

func is_auto() -> bool:
	return is_auto

func is_reloading() -> bool:
	if !anim.has_animation("reload"):
		return false
	return anim.current_animation == "reload"

puppet func _play_anim(anim_name:String):
	if is_network_master(): # Gun animations shows on other's games aswell
		rpc("_play_anim", anim_name)
	if anim.has_animation(anim_name):
		anim.stop()
		anim.play(anim_name)
		return
	push_warning("Weapon had no animation: " + anim_name)

# Signals #

func _on_animation_finish(anim_name:String):
	if !visible:
		return
	
	if anim_name == "reload":
		cur_ammo = max_ammo
	# Auto Reload
	elif anim_name == "attack1" and cur_ammo == 0: 
		reload()
