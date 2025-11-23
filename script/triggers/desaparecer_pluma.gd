extends Area3D

@onready var pluma: Node3D = $"../pluma_espacioColeccionable/Pluma_Antigua"
@onready var particle: GPUParticles3D = $"../GPUParticles3D2"
@onready var sonido_pluma = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/aura/Aura4-RV.wav")
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable2.tscn")

var puede_activarse := true

func _ready() -> void:
	# Si ya se obtuvo antes en esta partida, ocultarla al cargar la escena
	if AudioManager.pluma_obtenida:
		_apagar_visuales()
		monitoring = false
		collision_layer = 0
		collision_mask = 0
		return

	# (opcional) Pequeño delay si quieres prevenir activaciones instantáneas
	await get_tree().create_timer(0.1).timeout
	puede_activarse = true


func _on_body_entered(body: Node3D) -> void:
	if not puede_activarse:
		return
	if body == null:
		return
	# Aceptamos nombre "Player" o grupo "Player"
	if body.name != "Player" and not body.is_in_group("Player"):
		return

	# Si ya fue obtenida, no hacer nada
	if AudioManager.pluma_obtenida:
		return

	print("Coleccionable Pluma: Player entró — frame:", Engine.get_frames_drawn())

	# Marcar obtenido y desactivar inmediatamente para evitar reentradas
	AudioManager.pluma_obtenida = true
	puede_activarse = false
	# evitar futuros triggers físicos
	set_deferred("monitoring", false)
	collision_layer = 0
	collision_mask = 0

	# Ocultar pluma y detener partículas
	_apagar_visuales()

	# Reproducir sonido corto del coleccionable
	_reproducir_sonido_coleccionable(sonido_pluma)

	# Reproducir diálogo a través de AudioManager de forma segura
	# Si ya hay un diálogo en progreso, esperamos hasta que termine (evita solapamientos)
	var am = get_node_or_null("/root/AudioManager")
	if am:
		# si está ocupada la reproducción, esperar a que termine (opcional)
		if am.dialogo_en_progreso:
			print("Coleccionable Pluma: esperando a que termine diálogo en curso...")
			await am.esperar_dialogo_anterior() # tu función auxiliar en AudioManager
			# pequeña espera para seguridad
			await get_tree().process_frame

		print("Coleccionable Pluma: solicitando play_dialogo_aura ->", dialogo_aura.resource_path)
		am.play_dialogo_aura(dialogo_aura)
	else:
		# Fallback: reproducir con un player temporal y confiar en SubtitleManager fallback (si no existe)
		print("Coleccionable Pluma: AudioManager no encontrado, usando fallback temporal.")
		await _reproducir_dialogo_fallback(dialogo_aura)

	# Mostrar notificación visual
	_mostrar_notificacion()

	# Finalmente, eliminar el nodo para evitar cualquier posible reactivación
	# (si prefieres conservar el nodo, comenta la siguiente línea)
	queue_free()


func _apagar_visuales() -> void:
	if pluma:
		pluma.visible = false
	if particle:
		particle.emitting = false


func _reproducir_sonido_coleccionable(sound: AudioStream) -> void:
	if sound == null:
		print("Pluma: resource de sonido es null")
		return

	var am = get_node_or_null("/root/AudioManager")
	if not am:
		# Fallback: reproducir con un player temporal en el root
		_play_temp_sfx(sound)
		return

	# Si AudioManager tiene función específica, usarla
	if am.has_method("play_sonidoPluma"):
		am.play_sonidoPluma(sound)
		return

	# Si tiene play_sfx, usarla
	if am.has_method("play_sfx"):
		am.play_sfx(sound)
		return

	# Fallback: reproducir con player temporal
	_play_temp_sfx(sound)


func _reproducir_dialogo_fallback(stream: AudioStream) -> void:
	# Reproduce diálogo con player temporal en bus "Dialogos" si existe
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	var idx = AudioServer.get_bus_index("Dialogos")
	if idx != -1:
		p.bus = "Dialogos"
	get_tree().get_root().add_child(p)
	p.play()
	var dur := 2.0
	if stream.has_method("get_length"):
		dur = stream.get_length()
	await get_tree().create_timer(dur).timeout
	if p and p.is_inside_tree():
		p.queue_free()


func _play_temp_sfx(sound: AudioStream) -> void:
	var tmp := AudioStreamPlayer.new()
	tmp.stream = sound
	var idx = AudioServer.get_bus_index("Efectos")
	if idx != -1:
		tmp.bus = "Efectos"
	get_tree().get_root().add_child(tmp)
	tmp.play()
	var dur := 2.0
	if sound.has_method("get_length"):
		dur = sound.get_length()
	await get_tree().create_timer(dur).timeout
	if tmp and tmp.is_inside_tree():
		tmp.queue_free()


func _mostrar_notificacion() -> void:
	if notificacion_scene:
		var notif = notificacion_scene.instantiate()
		get_tree().get_root().add_child(notif)
		if "visible" in notif:
			notif.visible = true
