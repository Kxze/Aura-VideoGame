extends PathFollow3D
@export var speed = .5

func _process(delta: float) -> void:
	if Odil.isMoving:
		progress_ratio += delta * speed
		
