extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	player.animation_player.play("idle")

func physics_update(_delta: float) -> void:
	# Aplicar gravedad
	player.velocity.y += player.gravity * _delta
	player.move_and_slide()

	# --- Transiciones de estado ---
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("move_up") and player.is_on_floor():
		finished.emit((JUMPING),{"jump" : true}) 
	elif Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		finished.emit(RUNNINGLEFT)
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		finished.emit(RUNNINGRIGHT)
	# Si ambas teclas están presionadas → se queda en Idle
