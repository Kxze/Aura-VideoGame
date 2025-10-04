extends PlayerState

# Se ejecuta al entrar al estado
func enter(previous_state_path : String, data := {}):
	player.animationPlayer.play("Fall")  # Reproducir animación de caída

# Física del jugador
func physics_update(delta: float):
	# Aplicar gravedad
	player.velocity.y += player.GRAVITY

	# Movimiento horizontal suave
	player.velocity.x = lerp(player.velocity.x, player.movInput.x * player.speed, 0.1)

	# Si toca el suelo, cambiar a Idle
	if player.is_on_floor():
		emit_signal("finished", "Idle")

	# Movimiento final
	player.move_and_slide()
	if player.is_on_ceiling() and player.velocity.y > 0:
		player.velocity.y = 0
	player.global_position.z = 0

# Actualización del estado (animaciones de caminar en el aire si quieres)
func update(_delta: float):
	pass  # Normalmente no necesitamos nada aquí para Fall

# Input mientras está en caída

func exit():
	pass
