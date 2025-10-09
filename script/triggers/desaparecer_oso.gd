extends Area3D

@onready var osopeluche: MeshInstance3D = $"../OSO_EspacioColeccionable/OSOPELUCHE"
@onready var particulas_oso: GPUParticles3D = $"../GPUParticles3D"
@onready var sonido_oso = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/aura/Aura3-RV.wav")  # 🎙️ diálogo de Aura
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable3.tscn")

func _ready() -> void:
	# 🧠 Si ya se obtuvo antes en esta partida, ocultarlo al cargar la escena
	if AudioManager.oso_obtenido:
		osopeluche.visible = false
		particulas_oso.emitting = false
		monitoring = false
		collision_layer = 0
		collision_mask = 0

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	# 🚫 Si ya fue recogido, no hacer nada
	if AudioManager.oso_obtenido:
		return

	# 🧸 Apagar partículas y ocultar el oso
	osopeluche.visible = false
	particulas_oso.emitting = false

	# 🔒 Marcar globalmente como obtenido
	AudioManager.oso_obtenido = true

	# 🔊 Reproducir sonido del coleccionable y diálogo de Aura
	var am = get_node_or_null("/root/AudioManager")
	if am:
		if am.has_method("play_sonidoOso"):
			am.play_sonidoOso(sonido_oso)
		if am.has_method("play_dialogo_aura"):
			am.play_dialogo_aura(dialogo_aura)
	else:
		print("⚠️ No se encontró AudioManager o sus métodos de sonido.")

	# 💬 Mostrar notificación visual temporal
	_mostrar_notificacion()

	# 🚫 Desactivar el área para que no vuelva a usarse
	monitoring = false
	collision_layer = 0
	collision_mask = 0


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)  # CanvasLayer se renderiza sobre todo el 3D
	notif.visible = true

	# 🕒 Esperar 4 segundos y luego eliminar la notificación
	await get_tree().create_timer(4.0).timeout
	if is_instance_valid(notif):
		notif.queue_free()
