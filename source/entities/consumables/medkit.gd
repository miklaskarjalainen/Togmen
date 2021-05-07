extends Spatial
class_name Consumable
# TODO MAKE THIS RELIABLE FOR NETWORKING #

onready var anim = get_node("model/AnimationPlayer")
onready var respawn_timer = get_node("respawn")

func _ready():
	visible = false
	set_network_master(1) # Host keeps this in track
	
	anim.connect("animation_finished", self, "_on_animation_finish")
	
	if is_network_master():
		# Medkit visible after 10 seconds from the start
		Net.connect("on_peer_connect", self, "_on_peer_connect")
		respawn_timer.start()

# Remote #
puppet func showup():
	print("RPC SHOW")
	if is_network_master():
		rpc("showup")
	anim.play("showup")
	visible = true

puppet func pickup():
	print("RPC PICKUP")
	if is_network_master():
		rpc("pickup")
	anim.play("pickup")

# Signals #

func _on_medkit_body_entered(body):
	if !visible:
		return
	if not body is Actor:        # If not player, we're not interested
		return
	
	if body.is_network_master(): # If it's a local player
		body.health += 50
	
	pickup()
	respawn_timer.start()

func _on_respawn():
	pickup()

func _on_peer_connect(id:int): # Only called if the player is host
	if visible:
		rpc_id(id, "showup")
		return
	rpc_id(id, "pickup")

func _on_animation_finish(anim_name:String):
	match anim_name:
		"pickup":
			visible = false
		_:
			anim.play("idle")
