extends Area3D

@onready var sonido_coleccionable = preload("res://sonidos/coleccionableCerca.wav")

var sonido_reproducido := false  # marca local

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	# activa lumiere si aplica
	if Player.can_lumiere:
		Player.lumiere_ready = true
		print("Coleccionable cerca")

	# sonido solo la primera vez
	if not sonido_reproducido:
		AudioManager.play_sfx(sonido_coleccionable)
		sonido_reproducido = true
		set_monitoring(false)


func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		Player.lumiere_ready = false
		print("El Coleccionable salió de tu rango")
