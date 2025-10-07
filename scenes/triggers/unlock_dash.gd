extends Area3D

@onready var sonido_desbloquea = preload("res://sonidos/desbloquea.wav")
@onready var notificacion_scene = preload("res://scenes/notificacionHabilidad.tscn")  # ⚡️ escena tipo CanvasLayer
@onready var dialogo_alex7 = preload("res://dialogos/alex/Alex7-IA.mp3")  # 🎙️ diálogo al desbloquear el dash


func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	# 🚫 Si ya fue desbloqueado, solo reactiva la habilidad
	if AudioManager.dash_desbloqueado:
		body.can_dash = true
		return

	# 🔓 Primera vez → desbloqueo completo
	body.can_dash = true
	AudioManager.dash_desbloqueado = true

	# 🔊 Sonido de desbloqueo persistente
	AudioManager.play_sfx_persistente(sonido_desbloquea)

	# 💬 Muestra notificación visual de habilidad desbloqueada
	_mostrar_notificacion()

	# 🎧 Reproduce el diálogo de Alex7 (espera si hay otro activo)
	_reproducir_dialogo_alex7()

	# 🚫 Desactiva el área (para que no vuelva a activarse)
	monitoring = false
	collision_layer = 0
	collision_mask = 0


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)  # CanvasLayer flota sobre el 3D
	notif.visible = true


func _reproducir_dialogo_alex7() -> void:
	# 🚫 No repetir si ya se escuchó
	if AudioManager.alex7_sonado:
		print("🔇 Diálogo Alex7 ya reproducido.")
		return

	AudioManager.alex7_sonado = true  # ✅ marcar reproducido

	# Esperar si hay otro diálogo activo (por ejemplo Alex3)
	if AudioManager.dialogo_en_progreso:
		print("🕓 Esperando a que termine el diálogo anterior antes de reproducir Alex7...")
		await AudioManager.esperar_dialogo_anterior()

	# 🎙️ Reproducir el diálogo de Alex7
	if AudioManager.has_method("play_dialogo_alex"):
		AudioManager.play_dialogo_alex(dialogo_alex7)
		print("🎧 Diálogo Alex7 iniciado.")
