extends Control

onready var scope = get_node("../scope")
onready var right = $right
onready var bottom= $bottom
onready var left  = $left
onready var top   = $top
onready var viewport_resolution := Vector2()

func _physics_process(_delta:float):
	if Gui.player == null:
		return
	viewport_resolution = GameSettings.get_value("resolution") / 2.0
	
	_update_color()
	_update_size()

func _update_color():
	var is_scoping = Gui.player.get_hand().get_weapon().is_scoping()
	if is_scoping or Gui.player.is_dead():
		scope.visible = true
	else: 
		# Gets the crosshair color from the settings, crosshair color can be set in the settings.ini
		modulate = GameSettings.get_value("crosshair_color", Color( 0.2, 0.8, 0.2, 1.0))
		scope.visible = false

func _update_size():
	var gap = 5
	var movement := float(Gui.player.motion.length() * 2.0)
	var recovery := float(Gui.player.get_hand().get_weapon().recovery_counter * 12.0)
	var motion:int = movement + recovery + gap
	
	right .rect_position.x =  viewport_resolution.x+motion
	bottom.rect_position.y =  viewport_resolution.y+motion
	left  .rect_position.x =  (viewport_resolution.x - left.rect_size.x)-motion
	top   .rect_position.y =  (viewport_resolution.y - top.rect_size.y)-motion

