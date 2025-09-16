extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.play("walk")

func physics_update(delta: float) -> void:
	# --- Inputs ---
	var left := Input.is_action_pressed("move_left")
	var right := Input.is_action_pressed("move_right")

	# --- Determinar dirección ---
	var direction := 0.0
	if left and not right:
		direction = -1.0
	elif right and not left:
		direction = 1.0
	elif left and right:
		# Ambas teclas presionadas → Idle
		finished.emit(IDLE)
		return

	# --- Movimiento ---
	player.velocity.x = direction * player.speed
	player.velocity.y += player.gravity * delta

	# --- Rotar pivote según dirección ---
	if direction != 0.0:
		player.pivot.scale.x = lerp(player.pivot.scale.x, direction, player.rotationSpeed * delta)

	# --- Aplicar movimiento ---
	player.move_and_slide()

	# --- Transiciones de estado ---
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("move_up"):
		finished.emit(JUMPING)
	elif direction == 0.0:
		finished.emit(IDLE)
