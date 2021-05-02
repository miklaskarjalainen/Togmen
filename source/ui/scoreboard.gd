extends Control

onready var entry = load("res://source/ui/scoreboard_entry.tscn")
onready var entries = $entries

func _ready():
	visible = false
	Net.connect("on_peer_disconnect", self, "_on_peer_disconnect")

func _physics_process(_delta):
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
	get_node(str(id)).queue_free()

# Signals #
func _on_peer_disconnect(id:int):
	remove_entry(id)
