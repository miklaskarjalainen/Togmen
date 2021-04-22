extends Node

const PORT = 25595 # Minecraft port lol
const MAX_CLIENTS = 5

# Methods #

func _ready():
	get_tree().connect("network_peer_connected", self,     "_on_player_connect")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnect")
	get_tree().connect("connected_to_server", self, "_on_connection_success")
	get_tree().connect("connection_failed", self,   "_on_connection_fail")
	get_tree().connect("server_disconnected", self, "_on_server_disconnect")

func create_server() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_CLIENTS)
	get_tree().network_peer = peer
	print("Server created, port: ", PORT)

func create_client(ip_addr:String) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip_addr, PORT)
	get_tree().network_peer = peer
	print("Client Created IP: %s Port: %s" % [ip_addr, PORT])


# Getters / Setters #

func quit() -> void:
	get_tree().network_peer = null

func is_host() -> bool:
	return get_tree().is_network_server()

# Signals #

func _on_player_connect(id:int) -> void:
	print("Player %s connected" % id)

func _on_player_disconnect(id:int) -> void:
	print("Player %s disconnected" % id)

func _on_connection_success() -> void:
	print("Connected to the server")

func _on_connection_fail() -> void:
	print("Connection failed, lol ur bad")

func _on_server_disconnect() -> void:
	print("Disconnected from the server")
