extends Control

onready var titlescreen = $titlescreen
onready var settings    = $settings

func _ready():
	_on_back_pressed()

func _on_back_pressed():
	# Scenes #
	titlescreen.visible = true
	settings.visible    = false

func _on_settings_pressed():
	# Scenes #
	titlescreen.visible = false
	settings.visible    = true
