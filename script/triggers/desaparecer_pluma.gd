extends Area3D

@onready var pluma: Node3D = $"../pluma_espacioColeccionable/Pluma_Antigua"
@onready var particle: GPUParticles3D = $"../GPUParticles3D2"
@onready var sonido_pluma = preload("res://sonidos/desbloqueaColeccionable.wav")

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	# 🪶 Apagar partículas y ocultar la pluma
	pluma.visible = false
	particle.emitting = false

	# 🔊 Reproducir sonido solo una vez (independiente del oso o casco)
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sonidoPluma"):
		am.play_sonidoPluma(sonido_pluma)
	else:
		print("⚠️ No se encontró AudioManager o el método play_sonidoPluma().")
