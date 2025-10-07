extends Area3D

@onready var pluma: Node3D = $"../pluma_espacioColeccionable/Pluma_Antigua"
@onready var particle: GPUParticles3D = $"../GPUParticles3D2"
@onready var sonido_pluma = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/aura/Aura4-RV.wav")  # 🎙️ diálogo Aura
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable.tscn")

func _ready() -> void:
	# 🧠 Si ya se obtuvo antes en esta partida, ocultarla al cargar la escena
	if AudioManager.pluma_obtenida:
		pluma.visible = false
		particle.emitting = false
		monitoring = false
		collision_layer = 0
		collision_mask = 0

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	# 🚫 Si ya fue obtenida, no hacer nada
	if AudioManager.pluma_obtenida:
		return

	# 🪶 Apagar partículas y ocultar la pluma
	pluma.visible = false
	particle.emitting = false

	# 🔒 Marcar globalmente como obtenida
	AudioManager.pluma_obtenida = true

	# 🔊 Reproducir sonido del coleccionable y diálogo de Aura
	var am = get_node_or_null("/root/AudioManager")
	if am:
		if am.has_method("play_sonidoPluma"):
			am.play_sonidoPluma(sonido_pluma)
		if am.has_method("play_dialogo_aura"):
			am.play_dialogo_aura(dialogo_aura)  # 🎧 voz sobre la música
	else:
		print("⚠️ No se encontró AudioManager o sus métodos de sonido.")

	# 💬 Mostrar notificación visual (CanvasLayer la maneja sola)
	_mostrar_notificacion()

	# 🚫 Desactivar el área
	monitoring = false
	collision_layer = 0
	collision_mask = 0


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)  # CanvasLayer se renderiza sobre todo el 3D
	notif.visible = true
