extends Area3D

@onready var sonido_casco = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/Aura/Aura2-RV.wav")

@onready var casco: Node3D = $"../pCube1_001"
@onready var gpu_particles_3d: GPUParticles3D = $"../../GPUParticles3D"
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable.tscn")

var puede_activarse := false

func _ready() -> void:
	if AudioManager.casco_obtenido:
		_apagar_visuales()
		monitoring = false
		return

	# 2. TIEMPO DE SEGURIDAD (Solución a tu problema)
	# Esperamos 1.0 segundo antes de permitir que el jugador active esto.
	# Si el jugador nace tocando el objeto, esto evitará que suene al instante.
	await get_tree().create_timer(1.0).timeout
	puede_activarse = true

func _on_body_entered(body: Node3D) -> void:
	if not puede_activarse:
		return

	if body.name != "Player" and not body.is_in_group("Player"):
		return

	if AudioManager.casco_obtenido:
		return

	# --- SECUENCIA DE DESBLOQUEO ---
	
	print("Jugador recogió el coleccionable")

	AudioManager.casco_obtenido = true

	_apagar_visuales()

	# 3. Reproducir Audio y Subtítulos
	if AudioManager.has_method("play_sonidoCasco"):
		AudioManager.play_sonidoCasco(sonido_casco)
	else:
		AudioManager.play_sfx(sonido_casco)

	if AudioManager.has_method("play_dialogo_aura"):
		AudioManager.play_dialogo_aura(dialogo_aura)
	else:
		print("ERROR: AudioManager no tiene play_dialogo_aura")

	# 4. Mostrar notificación
	_mostrar_notificacion()

	# 5. Desactivar el área de forma segura (evita crasheos)
	set_deferred("monitoring", false)


func _apagar_visuales() -> void:
	if casco:
		casco.visible = false
	if gpu_particles_3d:
		gpu_particles_3d.emitting = false

func _mostrar_notificacion() -> void:
	if notificacion_scene:
		var notif = notificacion_scene.instantiate()
		get_tree().root.add_child(notif)
		if "visible" in notif:
			notif.visible = true
