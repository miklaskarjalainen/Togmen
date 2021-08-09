extends Spatial

# Hides the object this script is attached to when the local player is far
# enough from the object.

export(float, 0, 256, 0.2) var hide_distance := 80.0

func _physics_process(_delta):
	if Gui.player == null:
		return
	optimize(self)

func optimize(node):
	var distance = abs(transform.origin.distance_to(Gui.player.transform.origin))
	if distance > hide_distance and node.name != "floor":
		visible = false
	else:
		visible = true
