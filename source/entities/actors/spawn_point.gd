extends Position3D
class_name PlayerSpawn

const RAY_LENGTH = 100
onready var finder = $finder

func _ready():
	if has_node("player"): # my old map used only position 3d's and not my custom class that i made later
		$player.visible = false
	if finder != null:
		finder.set_as_toplevel(true)
		finder.rotation = Vector3()

func can_see(node:Spatial) -> bool:
	if node == null:
		return false
	if finder == null:
		return true
	
	var direction:Vector3 = finder.global_transform.origin.direction_to(node.global_transform.origin)
	finder.cast_to = direction * RAY_LENGTH
	finder.force_raycast_update()
	return finder.get_collider() == node
