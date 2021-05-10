extends Node

signal on_skin_changed(material)

func hide():
	for child in get_children():
		if child is AnimationPlayer:
			continue
		child.visible = false

func hide_arms():
	$left_hand.visible = false
	$right_hand.visible = false

func show():
	for child in get_children():
		if child is AnimationPlayer:
			continue
		child.visible = true

func set_skin(index:int):
	print("Set skin to ",index)
	match index:
		0:
			change_skin(load("res://assets/props/player/skin_png.material"))
		1:
			change_skin(load("res://assets/props/player/skins/galaxy.material"))
		2:
			change_skin(load("res://assets/props/player/skins/cosmonaut.material"))
		_:
			change_skin(load("res://assets/props/player/skin_png.material"))

func change_skin(material:Material):
	for group in get_children():
		for child in group.get_children():
			if child is MeshInstance:
					_change_material(child, material)
			else: #Another Spatial
				for second in child.get_children():
					_change_material(second, material)
	
	call_deferred("emit_signal", "on_skin_changed", material)

func _change_material(node, material):
	node.set_material_override(material)
