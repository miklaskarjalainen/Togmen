extends NetObject
class_name Consumable

# TODO MAKE THIS RELIABLE FOR NETWORKING #

onready var respawn_timer = get_node("respawn")

func _ready():
	visible = false
	respawn_timer.start()
	connect("peer_interact", self, "_on_peer_interact")
	anim.connect("animation_finished", self, "_on_animation_finish")

# Signals #
func _on_peer_interact(id:int):
	if !visible:
		return
	
	if id == Gui.player.get_unique_id():
		Gui.player.health += 50
	
	if is_network_master():
		anim.play("pickup")
		respawn_timer.start()

func _on_respawn():
	if is_network_master():
		visible = true
		anim.play("showup")

func _on_animation_finish(anim_name:String):
	if anim_name == "pickup":
		visible = false
	elif anim_name == "showup":
		anim.play("idle")
	elif anim_name == "idle":
		anim.play("idle")
	pass
