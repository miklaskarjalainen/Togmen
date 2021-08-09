extends Spatial
class_name NetObject

# When a class inherits from this one the net code will be         #
# Automatically handled by this script, Giffi (Miklas Karjalainen) #

# Currently only used by the grenade, also this script barely works >.< #

signal peer_interact(id)

# If the "real" object is handled by a peer or by the host
# e.g Grenade by the thrower (aka peer), but
# things like medkits or other "for all" objects by the host.
export var bool_handled_by_host := true

func _ready():
	# ON PEER CONNECT #
	
	if bool_handled_by_host:
		set_network_master(1)
	else:
		var id = get_tree().get_network_unique_id()
		set_network_master(id)
	

func _physics_process(_delta:float):
	_handle_master_networking()

func _handle_master_networking():
	# Isn't responsible for this node
	if !is_network_master(): 
		return
	
	remote_visible(visible)
	remote_position(global_transform.origin)

# Networking #
puppet func remote_visible(value:bool):
	if is_network_master():
		rpc("remote_visible", value)
		return
	visible = value

puppet func remote_position(position:Vector3):
	if is_network_master():
		rpc("remote_position", position)
		return
	global_transform.origin = position
