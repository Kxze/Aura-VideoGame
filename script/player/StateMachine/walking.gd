extends PlayerState

func enter(previous_state_path : String, data := {}):
	player.animationPlayer.play("Walk")
	

func physics_update(delta: float):
	if !player.is_on_floor():
		emit_signal("finished", "InAir")
	if player.movInput.x == 0:
		emit_signal("finished", "Idle")
	#Aqui se resetea la velocidad de cuando el jugador deja de presionar shift
	player.speed = player.speed_normal
	if Input.is_action_pressed("run"):
		player.speed = player.speed_run
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		emit_signal("finished", "InAir", {"Jump" : true})
		
	
	if Input.is_action_just_pressed("Dash"):
		emit_signal("finished", "Dash")

	player.velocity.x = lerpf(player.velocity.x, player.movInput.x * player.speed, .9)
	player.move_and_slide()

# Eliminamos la variable local last_facing
# var last_facing := 1  # 1 = derecha, -1 = izquierda

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
