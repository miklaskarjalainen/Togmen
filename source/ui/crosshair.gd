extends Control

onready var scope = get_node("../scope")
onready var right = $right
onready var left  = $left
onready var bottom= $bottom
onready var top   = $top

onready var right_pos  = right.rect_position
onready var bottom_pos = bottom.rect_position
onready var left_pos   = left.rect_position
onready var top_pos    = top.rect_position

func _physics_process(_delta:float):
	if Gui.player == null:
		return
	
	_update_color()
	_update_size()

func _update_color():
	var is_scoping = Gui.player.get_hand().get_weapon().is_scoping()
	if is_scoping:
		scope.visible = true
	else: 
		# Gets the crosshair color from the settings, crosshair color can be set in the settings.ini
		modulate = GameSettings.get_value("crosshair_color", Color( 0.2, 0.8, 0.2, 1.0))
		scope.visible = false

func _update_size():
	var center = get_viewport().get_size_override() / 2
	var motion:int = int(Gui.player.motion.length() * 1.2)
	
	right .rect_position.x =  right_pos.x+motion
	bottom.rect_position.y =  bottom_pos.y+motion
	left  .rect_position.x =  left_pos.x-motion
	top   .rect_position.y =  top_pos.y-motion
	
	
	pass
