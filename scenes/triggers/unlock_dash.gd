extends Area3D

@onready var sonido_desbloquea = preload("res://sonidos/desbloquea.wav")

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	# 🔒 Si ya fue desbloqueado, no hacer nada
	if AudioManager.dash_desbloqueado:
		body.can_dash = true
		return

	# 🔓 Primera vez → activa dash y marca global
	body.can_dash = true
	AudioManager.dash_desbloqueado = true
	
# 🔊 Reproduce desde el AudioManager global (persistente)
	AudioManager.play_lampara_desbloqueo_persistente(sonido_desbloquea)
	
	# 🚫 Desactiva el área (ya no vuelve a sonar)
	monitoring = false
	collision_layer = 0
	collision_mask = 0
