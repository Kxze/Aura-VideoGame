extends Area3D

@onready var sonido_desbloquea = preload("res://sonidos/desbloquea.wav")
@onready var lampara: Sprite3D = $lampara
@onready var particulas: GPUParticles3D = $particulas
@onready var luz: OmniLight3D = $luz
@onready var notificacion_scene = preload("res://scenes/notificacionHabilidad.tscn")  # 💬 escena tipo CanvasLayer

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

	# 🚫 Desactiva el área (para que no vuelva a activarse)
	monitoring = false
	collision_layer = 0
	collision_mask = 0


func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)  # CanvasLayer se renderiza sobre el 3D
	notif.visible = true
