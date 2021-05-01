extends Particles

func _ready():
	emitting = true
	$sfx.play(0.0)

func _physics_process(_delta):
	if !emitting:
		queue_free()
