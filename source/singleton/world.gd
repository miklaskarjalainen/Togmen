extends Node

var peer_holder # peers node in source/scenes/game.tscn
var current_gamestate = GameState.TitleScreen

enum GameState{
	TitleScreen,
	InGame,
}

func is_ingame() -> bool:
	return current_gamestate == GameState.InGame

func is_in_titlescreen() -> bool:
	return current_gamestate == GameState.TitleScreen

func get_peer(id:int):
	assert(peer_holder)
	return peer_holder.get_peer(id)

func get_peer_name(id:int):
	assert(peer_holder)
	return peer_holder.get_peer(id).peer_data["peer_name"]

func get_peer_holder():
	return peer_holder
