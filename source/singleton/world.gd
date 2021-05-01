extends Node

var peer_holder

func get_peer(id:int):
	assert(peer_holder)
	return peer_holder.get_peer(id)

func get_peer_name(id:int):
	assert(peer_holder)
	return peer_holder.get_peer(id).peer_name

func get_peer_holder():
	assert(peer_holder)
	return peer_holder
