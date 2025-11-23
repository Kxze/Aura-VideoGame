extends Area3D

# --- REFERENCIAS VISUALES ---
@onready var pluma: Node3D = $"../pluma_espacioColeccionable/Pluma_Antigua"
@onready var particle: GPUParticles3D = $"../GPUParticles3D2"

# --- ASSETS (Audio y Escenas) ---
@onready var sonido_pluma = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/aura/Aura4-RV.wav")
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable2.tscn")

# --- NUEVO: Cargamos los subtítulos 2 ---
@onready var subtitulos_scene = preload("res://dialogos/Aura/subs_2.tscn") 

var puede_activarse := false

func _ready() -> void:
	# Si ya tenemos la pluma, borramos este objeto al cargar
	if AudioManager.pluma_obtenida:
		queue_free()
		return

	# Pequeño delay de seguridad al nacer
	await get_tree().create_timer(0.1).timeout
	puede_activarse = true

func _on_body_entered(body: Node3D) -> void:
	if not puede_activarse: return
	if body.name != "Player" and not body.is_in_group("Player"): return
	if AudioManager.pluma_obtenida: return

	print("Coleccionable Pluma: Recogido")

	# 1. Marcar como obtenido
	AudioManager.pluma_obtenida = true
	puede_activarse = false
	
	# 2. Apagar visuales inmediatamente
	_apagar_visuales()

	# 3. Reproducir Audio (Usando el AudioManager limpio)
	AudioManager.play_sfx(sonido_pluma)
	AudioManager.play_dialogo_aura(dialogo_aura)

	# 4. Mostrar UI (Notificación y Subtítulos)
	_mostrar_notificacion()
	_mostrar_subtitulos()

	# 5. Borrar el coleccionable (o desactivar monitoreo si prefieres que no desaparezca)
	set_deferred("monitoring", false)
	# queue_free() # Descomenta esto si quieres que el objeto se destruya totalmente

func _apagar_visuales() -> void:
	if pluma: pluma.visible = false
	if particle: particle.emitting = false

func _mostrar_notificacion() -> void:
	if notificacion_scene:
		var notif = notificacion_scene.instantiate()
		get_tree().root.add_child(notif)
		if "visible" in notif: notif.visible = true

# --- FUNCION PARA MOSTRAR SUBTITULOS 2 ---
func _mostrar_subtitulos() -> void:
	if subtitulos_scene:
		var subs = subtitulos_scene.instantiate()
		get_tree().root.add_child(subs)
