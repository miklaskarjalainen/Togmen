extends NetObject
class_name Consumable

onready var respawn_timer = get_node("respawn")
onready var area          = get_node("hitbox")
onready var anim          = get_node("model/AnimationPlayer")

func _ready():
	visible = false
	
	if is_network_master():
		anim.connect("animation_finished", self, "_on_animation_finish")
		respawn_timer.start()

func _physics_process(_delta:float):
	if !anim.is_playing():
		anim.play("idle")

# Remotes #
puppet func remote_anim(anim_name:String):
	if anim == null or anim_name == "":
		return
	
	if is_network_master():
		rpc("remote_anim", anim_name)
		return
	anim.play(anim_name)

puppet func remote_interact(id:int):
	if !visible:
		return
	
	if id == Gui.player.get_unique_id():
		Gui.player.health += 50
	
	if is_network_master():
		anim.play("pickup")
		respawn_timer.start()

# Signals #

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

func _on_body_enter(body):
	if !is_network_master():
		return
	if not body is Peer:
		return
	var id = body.get_unique_id()
	remote_interact(id)
