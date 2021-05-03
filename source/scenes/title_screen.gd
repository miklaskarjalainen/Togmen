extends Control

onready var IP_edit = $IP_edit
onready var name_edit = $name_edit
onready var host_btn = $host
onready var join_btn = $join

func _ready():
	Net.connect("on_connection_ready", self, "_on_connection_ready")
	IP_edit.text = GameSettings.get_value("default_ip", "127.0.0.1")

func _physics_process(delta:float) -> void:
	
	# Enabling / Disabling Buttons #
	host_btn.disabled = true
	join_btn.disabled = true
	if !name_edit.text.empty() and name_edit.text.length() < 17:
		host_btn.disabled = false
		if IP_edit.text.is_valid_ip_address():
			join_btn.disabled = false
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


# Signals #
func _on_host_pressed():
	Net.create_server()

func _on_join_pressed():
	var ip := IP_edit.text as String
	Net.create_client(ip)

func _on_connection_ready():
	Net.set_master_name(name_edit.text)
	get_tree().change_scene("res://source/scenes/game.tscn")
