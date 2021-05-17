extends Spatial

# This Handles the permissions and peer names #

const PEER = preload("res://source/entities/actors/player.tscn")

var current_map = null

func _ready():
	var id = get_tree().get_network_unique_id()
	set_network_master(id)
	
	GameWorld.peer_holder = self
	get_parent().connect("on_map_load", self, "_on_map_load")
	Net.connect("on_peer_connect", self, "_on_peer_connect")
	Net.connect("on_peer_disconnect", self, "_on_peer_disconnect")
	rpc_id(1, "_requested_playerlist")

func _physics_process(_delta:float):
	Debug.add_line("players", get_child_count())

func get_spawn() -> Transform:
	# Gets a random spawn
	var spawns:Array = current_map.get_node("spawns").get_children()
	var valid_spawns := []
	
	for spawn in spawns:
		var is_valid = true
		
		# Check if this spawn is valid
		for peer in get_children(): 
			if peer.is_dead():      # If is dead
				continue
			if spawn.can_see(peer): # Can see a player
				is_valid = false
				break
		
		# If previous spawn was valid
		if is_valid == true:
			valid_spawns.append(spawn)
			pass
	
	randomize()
	# If no valid spawns, just spawn to one xD
	if valid_spawns.size() == 0:
		randomize()
		var i      := randi() % spawns.size()
		return spawns[i].global_transform
	
	var i := randi() % valid_spawns.size()
	return valid_spawns[i].global_transform

func get_peer(id:int):
	return get_node(str(id))

func get_peer_name(id:int) -> String:
	return get_node(str(id)).peer_name

func _delete_peer(id:int):
	get_node(str(id)).queue_free()

func _create_peer(data:Dictionary):
	if has_node(str(data["id"])):
		push_warning("tried to create same peer twice!")
		return
	print("Created Peer: ", data)
	
	var instance  = PEER.instance()
	instance.name = str(data["id"])
	instance.peer_data = data
	instance.set_skin(data["skin"])
	instance.set_as_toplevel(true)
	instance.global_transform = get_spawn()
	
	instance.set_network_master(data["id"])
	
	add_child(instance)

func _create_peer_id(id:int):
	if has_node(str(id)):
		push_warning("tried to create same peer twice!")
		return
	print("Created Peer: ", id)
	
	var instance  = PEER.instance()
	instance.name = str(id)
	instance.global_transform = get_spawn()
	instance.set_as_toplevel(true)
	instance.set_network_master(id)
	add_child(instance)

# Networking #
master func _update_peers(list:PoolIntArray):
	print("Received: ", str(list))
	
	for id in list:
		_create_peer_id(id)

master func _on_peer_register(data:Dictionary):
	if has_node(str(data["id"])):
		get_node(str(data["id"])).register(data)
	else:
		_create_peer(data)

master func _requested_playerlist():
	if !Net.is_host(): # Game host sends a list of current peers to the new peer
		return
	
	# Construct the peer list
	var peer_list := []
	for child in get_children():
		peer_list.append(int(child.name))
	var id = get_tree().get_rpc_sender_id()
	rpc_id(id, "_update_peers", peer_list)

# Signals #
func _on_map_load(map):
	current_map = map
	_create_peer(Net.data)

func _on_peer_connect(id:int):
	_create_peer_id(id)

func _on_peer_disconnect(id:int):
	_delete_peer(id)
