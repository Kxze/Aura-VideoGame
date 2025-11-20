extends Area3D

@onready var particulas_oso: GPUParticles3D = $"../GPUParticles3D"
@onready var osopeluche: MeshInstance3D = $"../OSO_EspacioColeccionable/OSOPELUCHE"
@onready var sonido_oso = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/aura/Aura3-RV.wav")
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable3.tscn")

func _ready() -> void:
	# Si ya se obtuvo antes en esta partida, ocultarlo al cargar la escena
	if AudioManager.oso_obtenido:
		if osopeluche:
			osopeluche.visible = false
		if particulas_oso:
			particulas_oso.emitting = false
		monitoring = false
		collision_layer = 0
		collision_mask = 0

func _on_body_entered(body: Node3D) -> void:
	if body == null or body.name != "Player":
		return

	# Si ya fue recogido, no hacer nada
	if AudioManager.oso_obtenido:
		return

	# Detener partículas y ocultar visual
	if particulas_oso:
		particulas_oso.emitting = false
	if osopeluche:
		osopeluche.visible = false

	# Marcar globalmente como obtenido
	AudioManager.oso_obtenido = true

	# Reproducir sonido del coleccionable y diálogo (con fallback seguro)
	_reproducir_sonido_coleccionable(sonido_oso)
	_reproducir_dialogo_seguro(dialogo_aura)

	# Mostrar notificación visual
	_mostrar_notificacion()

	# Desactivar el área para que no vuelva a usarse
	monitoring = false
	collision_layer = 0
	collision_mask = 0


func _reproducir_sonido_coleccionable(sound: AudioStream) -> void:
	if sound == null:
		print("Oso: resource de sonido es null")
		return

	var am = get_node_or_null("/root/AudioManager")
	if not am:
		_play_temp_sfx(sound)
		return

	if am.has_method("play_sonidoOso"):
		am.play_sonidoOso(sound)
		return

	if am.has_method("play_sfx"):
		am.play_sfx(sound)
		return

	_play_temp_sfx(sound)


func _reproducir_dialogo_seguro(stream: AudioStream) -> void:
	if stream == null:
		print("Oso: resource de diálogo es null")
		return

	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_dialogo_aura"):
		am.play_dialogo_aura(stream)
		return

	# Fallback: reproducir diálogo con player temporal en bus "Dialogos" si existe
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
	var notif = notificacion_scene.instantiate()
	get_tree().get_root().add_child(notif)
	notif.visible = true
