extends Label

puppet var minutes := 0
puppet var seconds := 0

func _ready():
	set_network_master(1)
	Net.connect("on_connection_ready", self, "_on_connection")
	Net.connect("on_peer_connect",     self, "_on_peer_connect")
	visible = false

# Remotes #

# Signals #

func _on_connection():
	minutes = GameSettings.match_settings["matchtime"]
	text = "%s:%s" % [minutes, seconds]
	visible = true

func _on_second():
	if !Net.is_client_connected():
		return
	
	seconds -= 1
	if seconds < 0:
		if minutes > 0:
			minutes -= 1
			seconds = 59
	
	text = "%s:%s" % [minutes, seconds]

func _on_peer_connect(id:int):
	if Net.is_host():
		rset_id(id, "minutes", minutes)
		rset_id(id, "seconds", seconds)
