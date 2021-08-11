extends Label

export  var winlabel_path   : NodePath
export  var scoreboard_path : NodePath
onready var winlabel   = get_node(winlabel_path)
onready var scoreboard = get_node(scoreboard_path)

puppet var minutes := 0
puppet var seconds := 0

func _ready():
	# Host controlts this timer
	set_network_master(1)
	
	# Peer signals
	Net.connect("on_connection_ready", self, "_on_connection")
	Net.connect("on_peer_connect",     self, "_on_peer_connect")
	
	# Hide on startup
	visible = false
	winlabel.visible = false

func _physics_process(_delta:float):
	text = "Match Time: %s:%s" % [str(minutes), str(seconds).pad_zeros(2)]

# Signals #

func _on_connection():
	minutes = GameSettings.match_settings["matchtime"]
	seconds = 0
	
	visible = true

func _on_second():
	# Is connected to a server
	if !Net.is_client_connected():
		return
	# Needs to be host
	if !is_network_master():
		return
	# Game has't ended, this is set to lower value on end for a cool slowmotion effect.
	if Engine.time_scale != 1.0:
		return
	
	# Timer countdown
	seconds -= 1    # Minus second
	if seconds < 0: # Minus minute
		if minutes > 0:
			minutes -= 1
			seconds = 59
	
	# Update for all players
	rset("minutes", minutes)
	rset("seconds", seconds)
	
	# If time's up
	if seconds <= 0 and minutes <= 0:
		seconds = 0
		minutes = 0
		_match_ended()

func _on_peer_connect(id:int):
	if Net.is_host():
		rset_id(id, "minutes", minutes)
		rset_id(id, "seconds", seconds)

puppet func _match_ended():
	if is_network_master():
		rpc("_match_ended")
	
	# Slowdown Engine 
	Engine.time_scale = 0.08 # 8% of normal
	
	# Display winner.
	var winner_name = scoreboard.get_peer_with_most_kills().peer_data["peer_name"]
	winlabel.text = "%s WON THE ROUND!" % winner_name
	winlabel.visible = true
	
	# Wait 8 seconds then disconnect everyone.
	var wait_time := 8.0 # seconds
	var scaled     = wait_time * Engine.time_scale # Because engine gets slowed down
	yield(get_tree().create_timer(scaled), "timeout")
	Engine.time_scale = 1.0 # back to normal
	winlabel.visible = false
	Net.destroy_client()
