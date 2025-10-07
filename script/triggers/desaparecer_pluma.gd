extends Area3D
@onready var pluma: Node3D = $"../pluma_espacioColeccionable/Pluma_Antigua"
@onready var particle: GPUParticles3D = $"../GPUParticles3D2"


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		pluma.visible = false
		particle.emitting = false
		
