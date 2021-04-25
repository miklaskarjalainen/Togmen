extends CanvasLayer

onready var player := get_node("../..")

func _ready():
	if !player.is_network_master():
		queue_free()
