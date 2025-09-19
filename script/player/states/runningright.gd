extends PlayerState

@export var rotation_speed: float = 10.0  # velocidad de giro suave

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.play("walk")

func physics_update(delta: float) -> void:
	var input_left := Input.is_action_pressed("move_left")
	var input_right := Input.is_action_pressed("move_right")

	# --- Movimiento horizontal ---
	var direction := 0.0
	if input_right and not input_left:
		direction = 1
	elif input_left and not input_right:
		direction = -1

	# Aplicar velocidad horizontal
	player.velocity.x = direction * player.speed
	# Aplicar gravedad
	player.velocity.y += player.gravity * delta
	player.move_and_slide()

	# --- Rotación suave del sprite ---
	if direction != 0:
		var target_scale := direction  # 1 = derecha, -1 = izquierda
		player.pivot.scale.x = lerp(player.pivot.scale.x, target_scale, rotation_speed * delta)

	# --- Transiciones ---
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("move_up"):
		finished.emit((JUMPING),{"jump" : true}) 
	elif direction == 0:
		finished.emit(IDLE)
	elif direction == -1:
		finished.emit(RUNNINGLEFT)
