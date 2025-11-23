extends Area3D

# --- REFERENCIAS VISUALES ---
@onready var particulas_oso: GPUParticles3D = $"../GPUParticles3D"
@onready var osopeluche: MeshInstance3D = $"../OSO_EspacioColeccionable/OSOPELUCHE"

# --- ASSETS (Audio y Escenas) ---
@onready var sonido_oso = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/aura/Aura3-RV.wav")
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable3.tscn")

# --- NUEVO: Cargamos los subtítulos 3 ---
@onready var subtitulos_scene = preload("res://dialogos/Aura/subs_3.tscn")

var puede_activarse := false

func _ready() -> void:
	# Si ya tenemos el oso, eliminamos el objeto al cargar la escena
	if AudioManager.oso_obtenido:
		queue_free()
		return
	
	# Pequeño delay de seguridad para evitar activaciones instantáneas al nacer
	await get_tree().create_timer(0.1).timeout
	puede_activarse = true

func _on_body_entered(body: Node3D) -> void:
	if not puede_activarse: return
	
	# Verificamos que sea el Player
	if body.name != "Player" and not body.is_in_group("Player"): return
	
	if AudioManager.oso_obtenido: return

	print("Coleccionable Oso: Recogido")

	# 1. Marcar como obtenido
	AudioManager.oso_obtenido = true
	puede_activarse = false

	# 2. Apagar visuales
	_apagar_visuales()

	# 3. Reproducir Audio (Directo al nuevo AudioManager limpio)
	AudioManager.play_sfx(sonido_oso)
	AudioManager.play_dialogo_aura(dialogo_aura)

	# 4. Mostrar UI (Notificación y Subtítulos)
	_mostrar_notificacion()
	_mostrar_subtitulos()

	# 5. Desactivar monitoreo (o puedes usar queue_free() si prefieres borrarlo)
	set_deferred("monitoring", false)

func _apagar_visuales() -> void:
	if particulas_oso:
		particulas_oso.emitting = false
	if osopeluche:
		osopeluche.visible = false

func _mostrar_notificacion() -> void:
	if notificacion_scene:
		var notif = notificacion_scene.instantiate()
		get_tree().root.add_child(notif)
		if "visible" in notif:
			notif.visible = true

# --- FUNCION PARA MOSTRAR SUBTITULOS 3 ---
func _mostrar_subtitulos() -> void:
	if subtitulos_scene:
		var subs = subtitulos_scene.instantiate()
		get_tree().root.add_child(subs)
