extends CisneState

func enter(previous_state_path: String, data := {}):
	cisne.animationCisneNegro.play("Caminar")


func physics_update(delta: float):
	if not cisne.Target or not cisne.navAgent:
		emit_signal("finished", "Idle")
		return

	if cisne.isAgressive:
		var distancia = cisne.global_position.distance_to(cisne.Target.global_position)
		if distancia > cisne.max_distance_from_player:
			emit_signal("finished", "Idle")
			return

		# --- Dirección hacia el jugador ---
		cisne.navAgent.target_position = cisne.Target.global_position
		var next_point = cisne.navAgent.get_next_path_position()
		var direction = (next_point - cisne.global_position).normalized()

		# --- Movimiento ---
		cisne.velocity = direction * cisne.speed
		cisne.move_and_slide()

		# --- Invertir la escala según dirección ---
		if direction.x < -0.1:
			cisne.scale = Vector3(1, 1, 1)  # mira hacia la izquierda
		elif direction.x > 0.1:
			cisne.scale = Vector3(-1, 1, 1)   # mira hacia la derecha

		# --- Mantenerlo en plano (sin rotación en X/Z) ---
		cisne.rotation.x = 0
		cisne.rotation.z = 0

	else:
		emit_signal("finished", "Convert")
