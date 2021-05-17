extends Control

export var gametimer_path:NodePath

onready var entry = load("res://source/ui/scoreboard_entry.tscn")
onready var entries = $entries
onready var gametimer = get_node(gametimer_path)

func _ready():
	visible = false
	Net.connect("on_peer_disconnect", self, "_on_peer_disconnect")
	Net.connect("on_server_disconnect", self, "_on_server_disconnect")

func _physics_process(_delta:float):
	if Input.is_action_just_pressed ("toggle_scoreboard"):
		visible = true
	if Input.is_action_just_released("toggle_scoreboard"):
		visible = false

func add_entry(peer_node): # Added in player.gd ready()
	# Scoreboard entry
	var instance = entry.instance()
	instance.name = peer_node.name
	instance.link_peer(peer_node)
	entries.add_child(instance)

func remove_entry(id:int):
	if gametimer.minutes >= 1:
		entries.get_node(str(id)).queue_free()
		return
	entries.get_node(str(id)).visible = false # if someone left right when the game was ending, he's score still will be stored.

# Getters / Setters #
func get_peer_with_most_kills():
	var current:Peer = null
	for child in entries.get_children():
		var peer:Peer = child.peer_node
		if peer == null:
			continue
		
		if current == null:
			current = peer
		elif current.kill_count < peer.kill_count:
			current = peer
	return current

# Signals #
func _on_peer_disconnect(id:int):
	remove_entry(id)

func _on_server_disconnect():
	for child in entries.get_children():
		child.link_peer(null) # the entries don't update if the current node is null
		child.queue_free()    # destroy the entry
 
