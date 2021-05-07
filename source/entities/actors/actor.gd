extends KinematicBody
class_name Actor

const MAX_HEALTH = 125

var health = 100

func _physics_process(_delta:float):
	health = clamp(health, 0, 125)

# Gives the node which contains all the peers
func get_peers_node():
	get_node("root/game/peers")

func has_max_health() -> bool:
	return health == MAX_HEALTH
