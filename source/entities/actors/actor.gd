extends KinematicBody
class_name Actor

var health = 100

# Gives the node which contains all the peers
func get_peers_node():
	get_node("root/game/peers")
