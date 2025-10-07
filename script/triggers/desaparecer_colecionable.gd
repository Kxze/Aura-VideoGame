extends Area3D

@onready var casco: Node3D = $"../pCube1_001"
@onready var gpu_particles_3d: GPUParticles3D = $"../../GPUParticles3D"

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		casco.visible = false
		gpu_particles_3d.emitting = false
