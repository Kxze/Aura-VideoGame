extends Area3D

@onready var sonido_casco = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/Aura/Aura2-RV.wav")

@onready var casco: Node3D = $"../pCube1_001"
@onready var gpu_particles_3d: GPUParticles3D = $"../../GPUParticles3D"
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable.tscn")

# --- NUEVO: Cargamos la escena de los subtítulos ---
@onready var subtitulos_scene = preload("res://dialogos/Aura/subs1.tscn") # <--- AJUSTA LA RUTA SI ES DIFERENTE

var puede_activarse := false

func _ready() -> void:
	if AudioManager.casco_obtenido:
		_apagar_visuales()
		monitoring = false
		return

	await get_tree().create_timer(1.0).timeout
	puede_activarse = true

func _on_body_entered(body: Node3D) -> void:
	if not puede_activarse: return
	if body.name != "Player" and not body.is_in_group("Player"): return
	if AudioManager.casco_obtenido: return
	
	print("Jugador recogió el coleccionable")
	AudioManager.casco_obtenido = true
	_apagar_visuales()

	# Reproducir Audio
	if AudioManager.has_method("play_sonidoCasco"):
		AudioManager.play_sonidoCasco(sonido_casco)
	else:
		AudioManager.play_sfx(sonido_casco)

	if AudioManager.has_method("play_dialogo_aura"):
		AudioManager.play_dialogo_aura(dialogo_aura)

	# Mostrar notificación
	_mostrar_notificacion()
	
	# --- NUEVO: Mostrar Subtítulos ---
	_mostrar_subtitulos() 

	set_deferred("monitoring", false)

func _apagar_visuales() -> void:
	if casco: casco.visible = false
	if gpu_particles_3d: gpu_particles_3d.emitting = false

func _mostrar_notificacion() -> void:
	if notificacion_scene:
		var notif = notificacion_scene.instantiate()
		get_tree().root.add_child(notif)
		if "visible" in notif: notif.visible = true

# --- NUEVO: Función para instanciar los subtítulos ---
func _mostrar_subtitulos() -> void:
	if subtitulos_scene:
		var subs = subtitulos_scene.instantiate()
		# Lo agregamos al root (pantalla completa) o al CanvasLayer del jugador
		get_tree().root.add_child(subs)
