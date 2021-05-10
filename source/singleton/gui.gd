extends Control


export  var health_color_r:Curve
export  var health_color_g:Curve

onready var elimination    := get_node("elimination")
onready var killstreak     := get_node("killstreak")
onready var scoreboard     := get_node("scoreboard")
var player = null # in player.gd "ready()" method this is set

func _ready():
	Net.connect("on_server_disconnect", self, "_on_server_disconnect")
	$hitmark.modulate.a = 0
	visible = false

func _physics_process(_delta:float):
	if player == null: # if player isn't set yet
		return
	if Input.is_action_just_pressed("toggle_ui"):
		visible = not visible
	if !visible:
		return
	
	_update_health()
	_update_ammo()

# Methods #

func register_peer(peer_node):
	scoreboard.add_entry(peer_node)

func set_player(_player):
	visible = true if _player != null else false # Makes the title screen visible if the player is not null
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
	$health.visible = not player.is_dead()
	
	# Displays player's current health
	var health:int = player.health
	var text_color := Color(0,0,0,1)
	text_color.r = health_color_r.interpolate(health/100.0)
	text_color.g = health_color_g.interpolate(health/100.0)
	$health.modulate = text_color
	
	
	$health.text = str(health)

func _update_ammo():
	$ammo.visible = not player.is_dead()
	
	# Displays player's current ammo
	var cur_weapon = player.get_hand().get_weapon()
	if cur_weapon.get_max_ammo() != 0:
		$ammo.text = str(cur_weapon.get_cur_ammo())
	else:
		$ammo.text = ""

# Signals #

func _on_server_disconnect():
	set_player(null)
