extends PlayerState

var fall_start_y: float = 0.0        # Guarda la altura donde comenzó la caída
var altura_minima_fall: float = 1.0  # Altura mínima para reproducir animación

func enter(previous_state_path : String, data := {}):
	pass

func physics_update(delta: float):
	# Si el jugador está en el suelo, actualizamos la altura de referencia
	if player.is_on_floor():
		fall_start_y = player.global_position.y
		# Si acabó de caer, cambiar a Idle
		emit_signal("finished", "Idle")
		return

	# Aplica gravedad
	player.velocity.y += player.GRAVITY

	# Movimiento horizontal suave
	player.velocity.x = lerp(player.velocity.x, player.movInput.x * player.speed, 0.1)

	# Comprobar altura de caída
	var altura_caida = fall_start_y - player.global_position.y
	if altura_caida > altura_minima_fall:
		if player.animationPlayer.current_animation != "Fall":
			player.animationPlayer.play("Fall")

	# Movimiento final
	player.move_and_slide()
	player.global_position.z = 0

	# Techo
	if player.is_on_ceiling() and player.velocity.y > 0:
		player.velocity.y = 0

func update(_delta: float):
	pass

func handled_input(_event: InputEvent):
	pass

func exit():
	pass
