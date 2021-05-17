extends Label

export  var winlabel_path   : NodePath
export  var scoreboard_path : NodePath
onready var winlabel   = get_node(winlabel_path)
onready var scoreboard = get_node(scoreboard_path)

puppet var minutes := 0
puppet var seconds := 0

func _ready():
	set_network_master(1)
	Net.connect("on_connection_ready", self, "_on_connection")
	Net.connect("on_peer_connect",     self, "_on_peer_connect")
	GameWorld.connect("on_game_end",     self, "_on_game_end")
	visible = false
	winlabel.visible = false

func _physics_process(_delta:float):
	text = str(minutes) + ":" + str(seconds).pad_zeros(2)

# Signals #

func _on_connection():
	minutes = GameSettings.match_settings["matchtime"]
	visible = true

func _on_second():
	if !Net.is_client_connected():
		return
	if !is_network_master():
		return
	
	# Countdown #
	seconds -= 1
	if seconds < 0:
		if minutes > 0:
			minutes -= 1
			seconds = 59
	
	rset("minutes", minutes)
	rset("seconds", seconds)

	if seconds <= 0 and minutes <= 0:
		seconds = 0
		minutes = 0
		print("Time's up")
		$second.stop() # Timer
		GameWorld.emit_signal("on_game_end")
	
func _on_peer_connect(id:int):
	if Net.is_host():
		rset_id(id, "minutes", minutes)
		rset_id(id, "seconds", seconds)

func _on_game_end():
	var winner_name = scoreboard.get_peer_with_most_kills().peer_data["peer_name"]
	winlabel.text = "%s WON THE ROUND!" % winner_name
	winlabel.visible = true
