extends Area3D

@onready var sonido_desbloquea = preload("res://sonidos/desbloquea.wav")

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	if AudioManager.lampara_desbloqueada:
		body.can_lumiere = true
		return

	body.can_lumiere = true

	# 🔥 Reproduce desde el AudioManager (ya no depende del área)
	AudioManager.play_lampara_desbloqueo_persistente(sonido_desbloquea)

	# 🚫 Desactiva el área para que nunca más dispare
	monitoring = false
	collision_layer = 0
	collision_mask = 0
