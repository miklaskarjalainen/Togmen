extends Control

onready var IP_edit = $IP_edit
onready var name_edit = $name_edit
onready var host_btn = $host
onready var join_btn = $join


func _physics_process(delta:float) -> void:
	host_btn.disabled = true
	join_btn.disabled = true
	if !name_edit.text.empty():
		host_btn.disabled = false
	if !name_edit.text.empty() && IP_edit.text.is_valid_ip_address():
		join_btn.disabled = false

func _on_host_pressed():
	Net.create_server()

func _on_join_pressed():
	var ip:String = IP_edit.text
	Net.create_client(ip)

