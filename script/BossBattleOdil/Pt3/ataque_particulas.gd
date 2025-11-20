extends GPUParticles3D
var speed = 20
var shoot_direction

func _process(delta: float) -> void:pass
	#position = shoot_direction * speed *delta
	
func set_shoot_direction(dir):
	shoot_direction = dir
