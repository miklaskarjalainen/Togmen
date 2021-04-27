extends Label

onready var anim := $anim

func _ready():
	modulate.a = 0

func eliminated(peer_name:String, web_name:String):
	var message := ""
	web_name  = web_name.to_lower()
	peer_name = peer_name.to_lower()
	
	add_color_override("font_color", Color.green)
	
	# Kill message #
	match web_name:
		"knife":
			message = "You KNIFED %s" % peer_name 
		"sniper":
			message = "You PWNED %s" % peer_name 
		_:
			message = "You ELIMINATED %s!" % peer_name
	text = message
	
	anim.stop(true)
	anim.play("show")

func killed_by(peer_name:String, web_name:String):
	var message := ""
	
	web_name  = web_name.to_lower()
	peer_name = peer_name.to_upper()
	
	add_color_override("font_color", Color.red)
	
	match web_name:
		"knife":
			message = "%s KNIFED YOU!" % peer_name 
		"sniper":
			message = "%s PWNED YOU" % peer_name 
		"suicide":
			message = "You took THE L!"
		_:
			message = "%s KILLED YOU!" % peer_name
	text = message
	
	anim.stop(true)
	anim.play("show")

func _on_anim_animation_finished(anim_name:String):
	if anim_name != "show":
		return
	anim.play("hide")
