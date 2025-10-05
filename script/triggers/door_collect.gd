extends Area3D 



func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Player.lumiere_ready = true
		print("Coleccionable cerca")



func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		Player.lumiere_ready = false
		print("El Coleccionable salio de tu rango")
