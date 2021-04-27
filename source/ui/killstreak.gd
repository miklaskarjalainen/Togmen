extends Label

onready var anim = $anim

func _ready():
	modulate.a = 0

func show_killstreak(peer_name:String, killstreak:int):
	var message := ""
	message = "%s has a %s KILLSTREAK!" % [peer_name, killstreak]
	text = message
	
	anim.stop(true)
	anim.play("show")

func _on_animation_finished(anim_name:String):
	if anim_name != "show":
		return
	anim.play("hide")
