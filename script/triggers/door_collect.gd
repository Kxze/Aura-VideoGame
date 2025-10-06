extends Area3D

@onready var sonido_coleccionable = preload("res://sonidos/coleccionableCerca.wav")

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and Player.can_lumiere:
		Player.lumiere_ready = true
		print("Coleccionable cerca")

		if AudioManager:
			AudioManager.play_coleccionable_cerca(sonido_coleccionable)

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		Player.lumiere_ready = false
		print("El Coleccionable salió de tu rango")
