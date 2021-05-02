extends Control

onready var bg               = $bg
onready var name_label       = $name
onready var kills_label      = $kills
onready var deaths_label     = $deaths
onready var killstreak_label = $killstreak
var peer_node = null

func link_peer(_peer_node):
	
	# Small color differences for "Host" and for the "Current Player"
	if _peer_node.name == "1":         # If this the current player
		$bg.color = Color.orange
		$bg.color.a = 0.4
	if _peer_node.is_network_master(): # If host
		add_color_override("font_color", Color.red)
	
	peer_node = _peer_node

func _physics_process(_delta):
	if !visible:
		return
	update_entry()

func update_entry():
	if peer_node == null:
		return
	
	name_label.text       = peer_node.peer_name
	kills_label.text      = str(peer_node.kill_count)
	deaths_label.text     = str(peer_node.death_count)
	killstreak_label.text = str(peer_node.killstreak)
