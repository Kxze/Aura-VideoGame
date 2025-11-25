extends PathFollow3D
@export var speed = .4

func _process(delta: float) -> void:
	if Odil.isMoving:
		progress_ratio += delta * speed
		
