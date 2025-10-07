extends PathFollow3D
@export var speed = .1

func _process(delta: float) -> void:
	if Odil.isMoving:
		progress_ratio += delta * speed
	else:
		progress_ratio = 28.6
