extends Label

onready var anim := $anim

func _ready():
	modulate.a = 0

func eliminated(peer_name:String, kill_type:String):
	var message := ""
	kill_type  = kill_type.to_lower()
	peer_name = peer_name.to_lower()
	
	add_color_override("font_color", Color.green)
	
	# Kill message #
	match kill_type:
		"knife":
			message = "You KNIFED %s" % peer_name 
		"sniper":
			message = "You SNIPED %s" % peer_name 
		"headshot":
			message = "You HEADSHOTTED %s!" % peer_name
		"noscope":
			message = "You NOSCOPED %s!" % peer_name
		"grenade":
			message = "You NADED %s!" % peer_name
		_:
			message = "You KILLED %s!" % peer_name
	text = message
	
	anim.stop(true)
	anim.play("show")

func killed_by(peer_name:String, kill_type:String):
	var message := ""
	
	kill_type  = kill_type.to_lower()
	peer_name = peer_name.to_upper()
	
	add_color_override("font_color", Color.red)
	
	match kill_type:
		"knife":
			message = "%s KILLED YOU with A KNIFE!" % peer_name 
		"sniper":
			message = "%s SNIPED YOU" % peer_name 
		"suicide":
			message = "You took THE L!"
		"headshot":
			message = "%s HEADSHOTTED YOU!" % peer_name
		"noscope":
			message = "%s NOSCOPED YOU!" % peer_name
		"grenade":
			message = "%s NADED YOU!" % peer_name
		_:
			message = "%s KILLED YOU!" % peer_name
	
	
	text = message
	
	anim.stop(true)
	anim.play("show")

func _on_anim_animation_finished(anim_name:String):
	if anim_name != "show":
		return
	anim.play("hide")
