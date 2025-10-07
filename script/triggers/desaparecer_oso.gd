extends Area3D
@onready var particulas_oso: GPUParticles3D = $"../GPUParticles3D"
@onready var osopeluche: MeshInstance3D = $"../OSO_EspacioColeccionable/OSOPELUCHE"


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		particulas_oso.emitting = false
		osopeluche.visible = false
