extends Area3D

@onready var sonido_casco = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var casco: Node3D = $"../pCube1_001"
@onready var gpu_particles_3d: GPUParticles3D = $"../../GPUParticles3D"
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable.tscn")

func _ready() -> void:
	# 🧠 Si ya se obtuvo antes en esta partida, esconderlo al cargar
	if AudioManager.casco_obtenido:
		casco.visible = false
		gpu_particles_3d.emitting = false
		monitoring = false
		collision_layer = 0
		collision_mask = 0

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	# 💡 Si ya estaba obtenido, no volver a ejecutar
	if AudioManager.casco_obtenido:
		return

	# 🪖 Oculta el casco y detiene las partículas
	casco.visible = false
	gpu_particles_3d.emitting = false

	# 🔒 Marca como obtenido globalmente
	AudioManager.casco_obtenido = true

	# 🔊 Reproduce el sonido solo una vez
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sonidoCasco"):
		am.play_sonidoCasco(sonido_casco)
	else:
		print("⚠️ No se encontró AudioManager o el método play_sonidoCasco().")

	# 💬 Muestra notificación visual
	_mostrar_notificacion()

	# 🚫 Desactiva el área
	monitoring = false
	collision_layer = 0
	collision_mask = 0


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)
	notif.visible = true
