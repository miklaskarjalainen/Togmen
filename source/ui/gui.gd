extends Control

export  var actor_path :NodePath

export  var health_color_r:Curve
export  var health_color_g:Curve

onready var actor_node := get_node(actor_path)


func _ready():
	if !actor_node.is_network_master():
		queue_free()
	$hitmark.modulate.a = 0

func _physics_process(_delta:float):
	_update_health()
	_update_ammo()
	_update_crosshair()

func _update_health():
	var health := actor_node.health as int
	var text_color := Color(0,0,0,1)
	text_color.r = health_color_r.interpolate(health/100.0)
	text_color.g = health_color_g.interpolate(health/100.0)
	$health.modulate = text_color
	$health.text = str(health)

func _update_ammo():
	var cur_weapon = actor_node.get_node("camera_lock/hand").get_weapon()
	if cur_weapon.get_max_ammo() != 0:
		$ammo.text = str(cur_weapon.get_cur_ammo())
	else:
		$ammo.text = ""

func _update_crosshair():
	$crosshair.modulate = GameSettings.get_value("crosshair_color", Color(1.0, 1.0, 1.0, 1.0))

func hitmark_play():
	$hitmark/anim.play("hit")
	$hitmark/sfx.play()
