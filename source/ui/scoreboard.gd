extends Control

onready var entry = load("res://source/ui/scoreboard_entry.tscn")
onready var entries = $entries

func _ready():
	visible = false

func _physics_process(_delta):
	if Input.is_action_just_pressed("toggle_scoreboard"):
		visible = true
	if Input.is_action_just_released("toggle_scoreboard"):
		visible = false

func add_entry(peer_node):
	
	# Scoreboard entry
	var instance = entry.instance()
	instance.link_peer(peer_node)
	entries.add_child(instance)
