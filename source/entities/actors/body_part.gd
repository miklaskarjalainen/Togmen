extends Area
class_name BodyPart

export(NodePath)             var player_path
export(float, 0.0, 5.0, 0.1) var multiplier = 1.0

onready var player = get_node(player_path)

func get_multiplier() -> int:
	return multiplier

func get_peer():
	return player

func get_peer_id() -> int:
	return int(player.name)
