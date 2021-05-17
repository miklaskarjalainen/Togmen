extends Node

const PORT = 25595

signal on_connection_ready # Created a server or connected to one
signal on_peer_connect(id)
signal on_peer_disconnect(id)
signal on_server_disconnect

var master_name := ""
var data := {
	"id":0,
	"peer_name":"",
	"skin":0,
}

func _ready():
	get_tree().connect("network_peer_connected",    self, "_on_peer_connect")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnect")
	get_tree().connect("connected_to_server",       self, "_on_connection_success")
	get_tree().connect("connection_failed",         self, "_on_connection_fail")
	get_tree().connect("server_disconnected",       self, "_on_server_disconnect")

func _exit_tree():
	peer_quit()

# Methods #
func create_server() -> void:
	var max_players = GameSettings.get_value("max_players", 5)
	var peer := NetworkedMultiplayerENet.new()
	var err = peer.create_server(PORT, max_players)
	
	# Catch an error
	match err:
		OK:
			pass
		ERR_CANT_CREATE:
			print("The port is already being used")
			return
		_:
			print("An error occurred, ", err)
			return
	
	# Set current network peer and save the id
	get_tree().network_peer = peer
	data["id"] = get_tree().get_network_unique_id()
	
	print("Server created, port: ", PORT)
	emit_signal("on_connection_ready")

func create_client(ip_addr:String) -> void:
	var peer := NetworkedMultiplayerENet.new()
	var err = peer.create_client(ip_addr, PORT)
	if err != OK:
		print("An error occurred, ", err)
	
	get_tree().network_peer = peer
	data["id"] = get_tree().get_network_unique_id()
	
	print("Client Created IP: %s Port: %s" % [ip_addr, PORT])

func destroy_client() -> void: # Disconnect
	get_tree().network_peer = null
	emit_signal("on_server_disconnect")

# Getters / Setters #
func set_master_name(peer_name:String):
	master_name = peer_name

func peer_quit() -> void:
	get_tree().network_peer = null

func is_client_connected() -> bool:
	return get_tree().network_peer != null

func is_host() -> bool:
	return get_tree().is_network_server()

# Signals #
func _on_peer_connect(id:int) -> void:
	print("Player %s connected" % id)
	emit_signal("on_peer_connect", id)

func _on_peer_disconnect(id:int) -> void:
	print("Player %s disconnected" % id)
	emit_signal("on_peer_disconnect", id)

func _on_connection_success() -> void:
	print("Connected to the server")

func _on_connection_fail() -> void:
	print("Connection failed, lol ur bad")

func _on_server_disconnect() -> void:
	print("Disconnected from the server")

