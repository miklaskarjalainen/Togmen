extends Control

func _ready():
	Net.connect("on_server_disconnect", self, "_on_back_button_up")

func _physics_process(delta:float):
	# Grap / Release mouse cursor #
	if Input.is_action_just_pressed("ui_cancel") and GameWorld.is_ingame(): 
		var cur := int(Input.get_mouse_mode() != 2)
		Input.set_mouse_mode(cur*2)
	
	if   Input.get_mouse_mode() == 0: # Not Captured
		visible = true
	elif Input.get_mouse_mode() == 2: # Captured
		visible = false

func _on_back_button_up():
	Net.destroy_client()
	get_tree().call_deferred("change_scene", "res://source/scenes/title_screen.tscn")

func _on_resume_button_up():
	Input.set_mouse_mode(2)

