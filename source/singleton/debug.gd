extends RichTextLabel

func _ready():
	if !OS.is_debug_build():
		visible = false

func _physics_process(_delta:float) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		visible = not visible
	if !visible:
		return
	
	_clear()
	add_line("FPS", Engine.get_frames_per_second())
	
	# Print IPs # prob should cache these?
	for ip in IP.get_local_interfaces():
		if ip["friendly"] == "Wi-Fi":
			add_line("IP", ip["addresses"][1])
		if ip["friendly"] == "Ethernet":
			add_line("IP", ip["addresses"][1])
	
	# Peer ID #
	if get_tree().network_peer != null:
		add_line("Peer ID", get_tree().get_network_unique_id())

func add_line(var_name:String, variable):
	text += "%s: %s\n" % [var_name, variable] 

func _clear():
	text = ""
