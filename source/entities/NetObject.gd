extends Spatial
class_name NetObject

# When a class inherits from this one the net code will be         #
# Automatically handled by this script, Giffi (Miklas Karjalainen) #

signal peer_interact(id)

export var bool_handled_by_host := true
export var anim_path:NodePath
export var area_path:NodePath

var anim
var area

func _ready():
	if anim_path != "":
		anim = get_node(anim_path)
	if area_path != "":
		area = get_node(area_path)
	
	
	# ON PEER CONNECT #s
	
	if bool_handled_by_host:
		set_network_master(1)
		if area != null and is_network_master():
			print("Wasn't null")
			area.connect("body_entered", self, "_on_body_enter")
	else:
		var id = get_tree().get_network_unique_id()
		set_network_master(id)
		if area != null and is_network_master():
			area.connect("body_entered", self, "_on_body_enter")
	

func _physics_process(_delta:float):
	_handle_master_networking()

func _handle_master_networking():
	# Isn't responsible for this node
	if !is_network_master(): 
		return
	
	remote_visible(visible)
	remote_position(global_transform.origin)
	if anim != null:
		remote_anim(anim.current_animation)

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

puppet func remote_anim(anim_name:String):
	if anim == null:
		return
	if anim_name == "":
		return
	
	if is_network_master():
		rpc("remote_anim", anim_name)
		return
	anim.play(anim_name)

puppet func remote_interact(id:int):
	if is_network_master():
		rpc("remote_interact", id)
	emit_signal("peer_interact", id)

# Signals #
func _on_body_enter(body):
	if !is_network_master():
		return
	if not body is Peer:
		return
	var id = body.get_unique_id()
	remote_interact(id)
