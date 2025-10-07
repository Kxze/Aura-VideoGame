extends Area3D

@onready var particulas_oso: GPUParticles3D = $"../GPUParticles3D"
@onready var osopeluche: MeshInstance3D = $"../OSO_EspacioColeccionable/OSOPELUCHE"
@onready var sonido_oso = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable.tscn")  # 👈 misma escena UI del casco

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	# 🧸 Apagar partículas y ocultar el oso
	particulas_oso.emitting = false
	osopeluche.visible = false

	# 🔊 Reproducir sonido del coleccionable (solo una vez)
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sonidoOso"):
		am.play_sonidoOso(sonido_oso)
	else:
		print("⚠️ No se encontró AudioManager o el método play_sonidoOso().")

	# 💬 Mostrar notificación visual (la escena se maneja sola)
	_mostrar_notificacion()


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)  # ✅ agrégala al root (CanvasLayer flota sobre todo)
	notif.visible = true
