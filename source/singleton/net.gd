extends Node

const PORT = 25595
const MAX_CLIENTS = 5

signal on_connection_ready # Created a server or connected to one
signal on_peer_connect(id)
signal on_peer_disconnect(id)


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
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_CLIENTS)
	get_tree().network_peer = peer
	
	print("Server created, port: ", PORT)
	emit_signal("on_connection_ready")

func create_client(ip_addr:String) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip_addr, PORT)
	get_tree().network_peer = peer
	
	print("Client Created IP: %s Port: %s" % [ip_addr, PORT])


# Getters / Setters #
func peer_quit() -> void:
	get_tree().network_peer = null

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
	emit_signal("on_connection_ready")

func _on_connection_fail() -> void:
	print("Connection failed, lol ur bad")

func _on_server_disconnect() -> void:
	print("Disconnected from the server")
