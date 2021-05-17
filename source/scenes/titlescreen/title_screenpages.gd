extends Control

onready var titlescreen = $titlescreen
onready var hostscreen  = $hostscreen
onready var settings    = $settings

func _ready():
	_on_back_pressed()

func _on_back_pressed():
	# Scenes #
	hostscreen.visible  = false
	titlescreen.visible = true
	settings.visible    = false

func _on_settings_pressed():
	# Scenes #
	hostscreen.visible  = false
	titlescreen.visible = false
	settings.visible    = true

func _on_host_pressed():
	# Scenes #
	hostscreen.visible  = true
	titlescreen.visible = false
	settings.visible    = false
