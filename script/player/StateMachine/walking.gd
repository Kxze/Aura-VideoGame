extends PlayerState

var isRunning : bool = false

func enter(previous_state_path : String, data := {}):
	player.animationPlayer.play("Walk")
	isRunning = false

func physics_update(delta: float):
	# --- Pasar a Fall si deja de tocar el suelo ---
	if !player.is_on_floor():
		emit_signal("finished", "Fall")
		return  # Salimos de physics_update para no seguir ejecutando el resto

	# Reset de velocidad si dejó de presionar run
	player.speed = player.speed_normal

	# --- Run / Walk Animations ---
	if Input.is_action_pressed("run"):
		isRunning = true
		player.speed = player.speed_run
		if isRunning and player.animationPlayer.current_animation != "Run":
			player.animationPlayer.play("Run")
	elif player.movInput.x != 0:
		isRunning = false
		if player.animationPlayer.current_animation != "Walk":
			player.animationPlayer.play("Walk")
	else:
		emit_signal("finished", "Idle")

	# --- Jump ---
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		emit_signal("finished", "InAir", {"Jump" : true})
		
	# --- Dash ---
	if Input.is_action_just_pressed("dash"):
		emit_signal("finished", "Dash")

	# --- Movimiento horizontal ---
	player.velocity.x = lerp(player.velocity.x, player.movInput.x * player.speed, 0.9)
	player.move_and_slide()
	player.global_position.z = 0

func update(_delta: float):
	if player.movInput.x != 0:
		var target_scale = 1 if player.movInput.x > 0 else -1

		# Solo lanza el flip si hay un cambio real de dirección
		if target_scale != player.last_facing:
			flip_character(target_scale)
			player.last_facing = target_scale  # actualizamos last_facing del Player

func flip_character(target_scale: int):
	var tween = create_tween()

	# Paso 1: squash
	tween.parallel().tween_property(player.aura, "scale:x", 0, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(player.aura, "scale:y", 1.2, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Paso 2: flip y normalizar
	tween.tween_property(player.aura, "scale:x", target_scale, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(player.aura, "scale:y", 1, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func accelerate(movInput: Vector2):
	player.velocity = player.velocity.move_toward(player.speed + player.movInput, player.acceleration)

func apply_friction():
	player.velocity = player.velocity.move_toward(Vector3.ZERO, player.friction)

func exit():
	pass
