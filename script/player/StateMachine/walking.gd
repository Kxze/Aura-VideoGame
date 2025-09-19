extends PlayerState
#este apartado sobreescribe el estado que viene
func enter(previous_state_path : String, data := {}):
	player.animationPlayer.play("walk")

#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	if !player.is_on_floor():
		emit_signal("finished", "InAir")
	if player.movInput.x == 0:
		emit_signal("finished", "Idle")
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		emit_signal("finished", "InAir", {"Jump" : true})
	player.velocity.x = lerpf(player.velocity.x, player.movInput.x * player.speed, .9)
	player.move_and_slide()

var last_facing := 1  # 1 = derecha, -1 = izquierda

func update(_delta: float):
	if player.movInput.x != 0:
		var target_scale = 1 if player.movInput.x > 0 else -1

		# Solo lanza el flip si hay un cambio real de dirección
		if target_scale != last_facing:
			flip_character(target_scale)
			last_facing = target_scale


func flip_character(target_scale: int):
	var tween = create_tween()

	# Paso 1: achicar en X y agrandar en Y (squash)
	tween.parallel().tween_property(player.aura, "scale:x", 0, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(player.aura, "scale:y", 1.2, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Paso 2: pasar al nuevo lado y volver a normalizar Y
	tween.tween_property(player.aura, "scale:x", target_scale, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(player.aura, "scale:y", 1, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)





#Esta funcion sobreescribe la funcion Input
func handled_input(_event: InputEvent):
	pass

func exit():
	pass
