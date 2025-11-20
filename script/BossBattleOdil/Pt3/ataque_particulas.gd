extends GPUParticles3D
var speed = 20
var shoot_direction

func _process(delta: float) -> void:
	#position = shoot_direction * speed *delta
	pass
func set_shoot_direction(dir):
	shoot_direction = dir
