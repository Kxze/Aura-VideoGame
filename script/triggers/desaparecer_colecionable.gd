extends Area3D

@onready var sonido_casco = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/aura/Aura2-RV.wav")
@onready var casco: Node3D = $"../pCube1_001"
@onready var gpu_particles_3d: GPUParticles3D = $"../../GPUParticles3D"
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable.tscn")

func _ready() -> void:
	# Si ya fue obtenido, desactivar visual y colisión
	if AudioManager.casco_obtenido:
		casco.visible = false
		if gpu_particles_3d:
			gpu_particles_3d.emitting = false
		monitoring = false
		collision_layer = 0
		collision_mask = 0

func _on_body_entered(body: Node3D) -> void:
	if body == null:
		return
	if body.name != "Player":
		return

	if AudioManager.casco_obtenido:
		return

	# Oculta el casco y detiene partículas
	casco.visible = false
	if gpu_particles_3d:
		gpu_particles_3d.emitting = false

	# Marca globalmente como obtenido
	AudioManager.casco_obtenido = true

	# Reproducir sound + diálogo de forma segura
	_reproducir_sonido_coleccionable(sonido_casco)
	_reproducir_dialogo_seguro(dialogo_aura)

	# Mostrar notificación visual
	_mostrar_notificacion()

	# Desactiva el área
	monitoring = false
	collision_layer = 0
	collision_mask = 0


func _reproducir_sonido_coleccionable(sound: AudioStream) -> void:
	if sound == null:
		print("Coleccionable: sound resource es null:", sound)
		return

	var am = get_node_or_null("/root/AudioManager")
	if not am:
		# Fallback: crear un AudioStreamPlayer temporal en este nodo
		print("Coleccionable: no se encontró AudioManager, usando fallback temporal.")
		_play_temp_sfx(sound)
		return

	# Si el AudioManager tiene una función específica, usarla
	if am.has_method("play_sonidoCasco"):
		print("Coleccionable: llamando a AudioManager.play_sonidoCasco()")
		am.play_sonidoCasco(sound)
		return

	# Si tiene función genérica, usarla
	if am.has_method("play_sfx"):
		print("Coleccionable: AudioManager.play_sfx() disponible, usándola.")
		am.play_sfx(sound)
		return

	# Fallback: si ninguna función existe, reproducir con un player temporal
	print("Coleccionable: no hay métodos en AudioManager, usando fallback temporal.")
	_play_temp_sfx(sound)


func _reproducir_dialogo_seguro(stream: AudioStream) -> void:
	if stream == null:
		print("Coleccionable: diálogo resource es null:", stream)
		return

	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_dialogo_aura"):
		print("Coleccionable: llamando a AudioManager.play_dialogo_aura()")
		am.play_dialogo_aura(stream)
	else:
		# Fallback simple: reproducir diálogo con player temporal en bus Dialogos (si existe)
		print("Coleccionable: play_dialogo_aura no disponible; reproducir con temp player.")
		var p := AudioStreamPlayer.new()
		p.stream = stream
		var idx = AudioServer.get_bus_index("Dialogos")
		if idx != -1:
			p.bus = "Dialogos"
		get_tree().get_root().add_child(p)
		p.play()
		# liberar después de la duración conocida
		if stream.has_method("get_length"):
			var dur := stream.get_length()
			await get_tree().create_timer(dur).timeout
		else:
			await get_tree().create_timer(2.0).timeout
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
	tmp.queue_free()


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)
	notif.visible = true
