extends Control

export(NodePath) var player_model_path

onready var player_model_anim = get_node(player_model_path).get_node("AnimationPlayer")
onready var confirm_popup = $confirm_popup
onready var IP_edit = $IP_edit
onready var name_edit = $name_edit
onready var host_btn = $host
onready var join_btn = $join


func _ready():
	GameWorld.current_gamestate = GameWorld.GameState.TitleScreen
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Connect Signals #
	confirm_popup.connect("on_answer", self, "_on_popup_answer")
	Net.connect("on_connection_ready", self, "_on_connection_ready")
	
	# Get Previous IP #
	IP_edit.text = GameSettings.get_value("default_ip", "127.0.0.1")

func _physics_process(delta:float) -> void:
	# Player Idle Animation
	player_model_anim.play("showoff")
	
	# Enabling / Disabling Buttons #
	host_btn.disabled = true
	join_btn.disabled = true
	if !name_edit.text.empty() and name_edit.text.length() < 17:
		host_btn.disabled = false
		if IP_edit.text.is_valid_ip_address():
			join_btn.disabled = false
	
	# Ask the user if they really want to quit #
	if Input.is_action_just_pressed("ui_cancel"):
		confirm_popup.toggle_pop()

# Signals #
func _on_popup_answer(answered_yes:bool):
	if answered_yes:
		get_tree().quit()
		return

func _on_host_pressed():
	Net.create_server()

func _on_join_pressed():
	var ip:String = IP_edit.text
	Net.create_client(ip)

func _on_connection_ready():
	Net.set_master_name(name_edit.text)
	get_tree().change_scene("res://source/scenes/game.tscn")
