extends Label

onready var anim = $anim

func _ready():
	modulate.a = 0

func ended_killstreak(ender_name:String, killreaker_name:String, killstreak:int):
	var message := ""
	message = "%s ENDED %s's %s KILLSTREAK!" % [ender_name, killreaker_name, killstreak]
	text = message
	
	anim.stop(true)
	anim.play("show")

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
