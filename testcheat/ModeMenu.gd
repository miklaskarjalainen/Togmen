extends Control

onready var aimbot   = $modmenu/aimbot
onready var wallhack = $modmenu/wallhack

var closest_player = null
var target_distance:float

func _ready():
	visible = true
	$modmenu.visible = false

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_INSERT:
			$modmenu.visible = not $modmenu.visible
	if event is InputEvent and event.is_pressed():
		if event.is_action("shoot") and aimbot.pressed:
			player_look_at()

func _physics_process(delta):
	if !GameWorld.is_ingame():
		return
	
	update_hacks() # Updates all the stats
	
	if Input.is_action_pressed("shoot") and aimbot.pressed:
		player_look_at()

func player_look_at():
	if closest_player == null:
		return
	
	var other = closest_player.get_node("camera").global_transform.origin
	var player = Gui.player
	player.look_at(other, Vector3.UP)
	player.rotation.x = 0
	player.rotation.z = 0
	
	player.get_node("camera").look_at(other, Vector3.UP)
	player.get_node("camera").rotation.y = 0

func update_hacks():
	closest_player = null
	
	if GameWorld.get_peer_holder() == null:
		return
	var all_peers = GameWorld.get_peer_holder().get_children()
	
	for peer in all_peers:
		# Player #
		if peer == Gui.player: 
			continue
		
		# Do WH #
		var peer_distance = peer.get_node("camera").global_transform.origin.distance_to(Gui.player.global_transform.origin)     
		_add_wh_box(peer, peer_distance)
		
		# Get Closest To Player #
		if peer.is_dead():
			continue
		if closest_player == null:
			# Assigning new target #
			closest_player    = peer
			target_distance   = peer_distance
		else:
			if peer_distance < target_distance:
				# Assigning new target #
				closest_player  = peer
				target_distance = peer_distance


func _add_wh_box(peer, distance:float):
	if !wallhack.pressed:
		if has_node(peer.name):
			get_node(peer.name).queue_free()
		return
	if peer.is_dead() and has_node(peer.name):
		get_node(peer.name).rect_size = Vector2()
		return
	
	var camera = get_tree().get_root().get_camera()
	var pos = camera.unproject_position(peer.global_transform.origin)
	var esp_box = get_node_or_null(peer.name)
	
	if esp_box == null:
		esp_box = ColorRect.new()
		esp_box.color = Color.red
		esp_box.name = peer.name
		add_child(esp_box)
	
	esp_box = esp_box as ColorRect
	esp_box.rect_position  = pos
	esp_box.rect_position -= esp_box.rect_size / 2
	esp_box.rect_size = Vector2(16,36) / (distance*0.01)
	esp_box.color.a = 0.5