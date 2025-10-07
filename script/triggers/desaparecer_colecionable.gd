extends Area3D

@onready var sonido_casco = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var casco: Node3D = $"../pCube1_001"
@onready var gpu_particles_3d: GPUParticles3D = $"../../GPUParticles3D"
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable.tscn")  # ⚡ tu escena UI con el script automático

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	# 🪖 Oculta el casco y detiene las partículas
	casco.visible = false
	gpu_particles_3d.emitting = false

	# 🔊 Reproduce el sonido solo una vez desde el AudioManager
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sonidoCasco"):
		am.play_sonidoCasco(sonido_casco)
	else:
		print("⚠️ No se encontró AudioManager o el método play_sonidoCasco().")

	# 💬 Muestra notificación visual (la escena se maneja sola)
	_mostrar_notificacion()


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().current_scene.add_child(notif)  # 👈 agrégala al árbol actual
	notif.visible = true  # 👈 listo, no hace falta nada más
