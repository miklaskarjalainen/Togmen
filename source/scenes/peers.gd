extends Spatial

# This Handles the permissions and peer names #

const PEER = preload("res://source/entities/actors/player.tscn")

func _ready():
	var id = get_tree().get_network_unique_id()
	set_network_master(id)
	
	Net.connect("on_peer_connect", self, "_on_peer_connect")
	Net.connect("on_peer_disconnect", self, "_on_peer_disconnect")
	
	_create_peer(id)

func _delete_peer(id:int):
	get_node(str(id)).queue_free()

func _create_peer(id:int):
	if has_node(str(id)):
		push_warning("tried to create same peer twice!")
		return
	
	var instance = PEER.instance()
	instance.name = str(id)
	instance.translation = Vector3(0,0,0)
	instance.set_as_toplevel(true)
	instance.set_network_master(id)
	add_child(instance)

# Networking #

remote func _update_peers(list:Array):
	for peer_id in list:
		_create_peer(peer_id)

# Signals #

func _on_peer_connect(id:int):
	if is_network_master(): # Game host send list of current peers to the new peer
		var peer_list := []
		for child in get_children():
			peer_list.append(int(child.name))
		rpc_id(id, "_update_peers", peer_list)
	
	_create_peer(id)
	
func _on_peer_disconnect(id:int):
	_delete_peer(id)
