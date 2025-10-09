extends Area3D

@onready var sonido_desbloquea = preload("res://sonidos/desbloquea.wav")
@onready var notificacion_scene = preload("res://scenes/notificacionHabilidad2.tscn")  # 💬 escena tipo CanvasLayer


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


	# 🚫 Desactiva el área (para que no vuelva a activarse)
	monitoring = false
	collision_layer = 0
	collision_mask = 0


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)  # CanvasLayer flota sobre el 3D
	notif.visible = true
