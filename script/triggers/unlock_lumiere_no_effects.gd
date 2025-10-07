extends Area3D

@onready var sonido_desbloquea = preload("res://sonidos/desbloquea.wav")
@onready var lampara: Sprite3D = $lampara
@onready var particulas: GPUParticles3D = $particulas
@onready var luz: OmniLight3D = $luz
@onready var notificacion_scene = preload("res://scenes/notificacionHabilidad.tscn")  # 💬 escena tipo CanvasLayer
@onready var dialogo_alex3 = preload("res://dialogos/alex/Alex3-IA_PE.wav")  # 🎙️ diálogo al desbloquear la lámpara


func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	
	# 💡 Si ya estaba desbloqueada, solo reactiva la habilidad
	if AudioManager.lampara_desbloqueada:
		body.can_lumiere = true
		return
	
	# 🔓 Primera vez → desbloqueo completo
	lampara.visible = false
	particulas.emitting = false
	luz.visible = false
	body.can_lumiere = true
	AudioManager.lampara_desbloqueada = true

	# 🔊 Sonido de desbloqueo persistente
	AudioManager.play_sfx_persistente(sonido_desbloquea)

	# 💬 Muestra notificación visual de habilidad desbloqueada
	_mostrar_notificacion()

	# 🎧 Reproduce el diálogo de Alex3 (espera si hay otro activo)
	_reproducir_dialogo_alex3()

	# 🚫 Desactiva el área (para que no vuelva a activarse)
	monitoring = false
	collision_layer = 0
	collision_mask = 0


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)  # CanvasLayer se renderiza sobre el 3D
	notif.visible = true


func _reproducir_dialogo_alex3() -> void:
	# 🚫 Evita repetir si ya se escuchó (usando el nuevo sistema por ID)
	if AudioManager.alex_dialogos_sonados.has("alex3") and AudioManager.alex_dialogos_sonados["alex3"]:
		print("🔇 Diálogo Alex3 ya fue reproducido anteriormente.")
		return

	# 🕓 Espera si hay otro diálogo en curso
	if AudioManager.dialogo_en_progreso:
		print("🕓 Esperando a que termine el diálogo anterior antes de reproducir Alex3...")
		await AudioManager.esperar_dialogo_anterior()

	# 🎙️ Reproduce el diálogo con ID único "alex3"
	if AudioManager.has_method("play_dialogo_alex"):
		AudioManager.play_dialogo_alex(dialogo_alex3, "alex3")
		print("🎧 Diálogo Alex3 iniciado correctamente.")
