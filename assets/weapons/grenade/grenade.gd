extends RigidBody


func _physics_process(delta):
	if $grenade.visible == false:
		if $smoke.emitting == false:
			queue_free()

func _on_explode_timeout():
	sleeping = true
	$smoke.emitting = true
	$grenade.visible = false
