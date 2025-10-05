extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		# Opcional: desactivar controles durante la transición
		body.controls_enabled = false

		# Transición de pantalla
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished

		# Mover al jugador al spawnPoint
		if Player.spawnPoint:
			body.global_position = Player.spawnPoint.global_position
			body.velocity = Vector3.ZERO  # Resetear velocidad
			body.controls_enabled = true
			body.animationPlayer.play("Idle")
		else:
			get_tree().reload_current_scene()
