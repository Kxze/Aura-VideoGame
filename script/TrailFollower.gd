extends Node3D

@export var target: Node3D
@export var lerp_speed: float = .1

func _process(delta):
	if target:
		global_position = global_position.lerp(target.global_position, lerp_speed)
