extends Node

# VirginSlayer is an anticheat system  #
# the name is shamelessly stolen from  # 
# the mario royale made by InfernoPlus #

const peer_data :=  {
	"position":Vector3(),
	"motion":Vector3(),
}

var peer_data_buffer := {
	
}

func _ready():
	print("Virgin Slayer started")

var timer := 0.0
func _physics_process(delta:float):
	if !GameWorld.is_ingame():
		return
	if GameWorld.get_peer_holder() == null:
		return
	
	for peer_node in GameWorld.get_peer_holder().get_children():
		# Creates a new entry #
		var id:String = peer_node.name
		if !peer_data_buffer.has(id):
			peer_data_buffer[id] = peer_data
		
		_check_movement(peer_node)
	
	
	# Print every 2 seconds #
	timer += delta
	if timer > 2.0:
		timer = 0.0
		print(str(peer_data_buffer))

func _check_movement(peer_node):
	var THRESHOLD := 0.08
	var id:String = peer_node.name
	
	# Distance without Y #
	var new_value:Vector3 = peer_node.global_transform.origin
	new_value.y = 0
	var old_value:Vector3 = peer_data_buffer[id]["position"]
	old_value.y = 0
	var move_distance = (new_value - old_value).length_squared()
	
	# Check #
	if move_distance > THRESHOLD:
		print(peer_node.name, " Moved too quickly!")
	
	peer_data_buffer[id]["position"] = new_value
