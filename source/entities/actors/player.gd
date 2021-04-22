extends KinematicBody

var motion := Vector3()

func _physics_process(delta:float) -> void:
	motion.y -= 2 * delta;
	motion = move_and_slide(motion, Vector3.UP)
