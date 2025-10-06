extends Area3D

@onready var sonido_desbloquea = preload("res://sonidos/desbloquea.wav")
@onready var lampara: MeshInstance3D = $lampara

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	
	if AudioManager.lampara_desbloqueada:
		body.can_lumiere = true
		return
	
	# Primera vez que se desbloquea
	lampara.visible = false
	body.can_lumiere = true
	AudioManager.lampara_desbloqueada = true

	AudioManager.play_sfx_persistente(sonido_desbloquea)

	# Desactiva el área
	monitoring = false
	collision_layer = 0
	collision_mask = 0
