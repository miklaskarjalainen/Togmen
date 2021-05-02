extends Control

onready var bg               = $bg
onready var name_label       = $name
onready var kills_label      = $kills
onready var deaths_label     = $deaths
onready var killstreak_label = $killstreak
var peer_node = null

func link_peer(_peer_node):
	# Small color differences for the "Current Player"
	peer_node = _peer_node
	if _peer_node == null:
		return
	
	if _peer_node.is_network_master():
		$bg.color = Color.orange
		$bg.color.a = 0.4

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
