extends Area3D

@onready var sonido_casco = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/aura/Aura2-RV.wav")  # 🎧 diálogo nuevo
@onready var casco: Node3D = $"../pCube1_001"
@onready var gpu_particles_3d: GPUParticles3D = $"../../GPUParticles3D"
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable.tscn")

func _ready() -> void:
	if AudioManager.casco_obtenido:
		casco.visible = false
		gpu_particles_3d.emitting = false
		monitoring = false
		collision_layer = 0
		collision_mask = 0

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	if AudioManager.casco_obtenido:
		return

	# 🪖 Oculta el casco y detiene partículas
	casco.visible = false
	gpu_particles_3d.emitting = false

	# 🔒 Marca globalmente como obtenido
	AudioManager.casco_obtenido = true

	# 🔊 Reproduce el sonido del coleccionable
	var am = get_node_or_null("/root/AudioManager")
	if am:
		if am.has_method("play_sonidoCasco"):
			am.play_sonidoCasco(sonido_casco)

		# 🎙️ Reproduce también el diálogo de Aura
		if am.has_method("play_dialogo_aura"):
			am.play_dialogo_aura(dialogo_aura)
	else:
		print("⚠️ No se encontró AudioManager o sus métodos de sonido.")

	# 💬 Notificación visual
	_mostrar_notificacion()

	# 🚫 Desactiva el área
	monitoring = false
	collision_layer = 0
	collision_mask = 0


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)
	notif.visible = true
