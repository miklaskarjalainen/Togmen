extends Control


export  var health_color_r:Curve
export  var health_color_g:Curve

onready var elimination    := get_node("elimination")
onready var killstreak     := get_node("killstreak")
onready var scoreboard     := get_node("scoreboard")
var player = null # in player.gd "ready()" method this is set

func _ready():
	$hitmark.modulate.a = 0

func _physics_process(_delta:float):
	if player == null: # if player isn't set yet
		return
	
	_update_health()
	_update_ammo()
	_update_crosshair()

# Methods #

func register_peer(peer_node):
	scoreboard.add_entry(peer_node)

func set_player(_player):
	player = _player

func hitmark_play():
	$hitmark/anim.play("hit")
	$hitmark/sfx.play()

func ended_killstreak(ender_name:String, killreaker_name:String, _killstreak:int):
	killstreak.ended_killstreak(ender_name, killreaker_name, _killstreak)

func show_killstreak(peer_name:String, peer_streak:int):
	killstreak.show_killstreak(peer_name, peer_streak)

func eliminated(peer_name:String, kill_type:String):
	# Killtype can be a gun name, headshot or noscope
	elimination.eliminated(peer_name, kill_type)

func killed_by(peer_name:String, kill_type:String):
	# Killtype can be a gun name, headshot or noscope
	elimination.killed_by(peer_name, kill_type)

func _update_health():
	# Displays player's current health
	var health:int = player.health
	var text_color := Color(0,0,0,1)
	text_color.r = health_color_r.interpolate(health/100.0)
	text_color.g = health_color_g.interpolate(health/100.0)
	$health.modulate = text_color
	$health.text = str(health)

func _update_ammo():
	# Displays player's current ammo
	var cur_weapon = player.get_hand().get_weapon()
	if cur_weapon.get_max_ammo() != 0:
		$ammo.text = str(cur_weapon.get_cur_ammo())
	else:
		$ammo.text = ""

func _update_crosshair():
	# Gets the crosshair color from the settings, crosshair color can be set in the settings.ini
	$crosshair.modulate = GameSettings.get_value("crosshair_color", Color( 0.2, 0.8, 0.2, 1.0))
