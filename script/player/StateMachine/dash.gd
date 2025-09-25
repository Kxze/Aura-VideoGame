extends PlayerState

var dash_time := 0.3
var dash_speed := 30
var timer := 0.0
var dash_dir := 1
var suspend_air_time := 0.5
var suspended := false

var dash_cooldown := 0.5

func enter(previous_state_path: String, data := {}):
	if not player.can_dash:
		emit_signal("finished", "Idle")
		return

	timer = 0.0
	dash_dir = player.last_facing
	player.is_dashing = true
	player.can_dash = false
	
	# Reproducir animación Dash
	if player.animationPlayer:
		player.animationPlayer.play("Dash")
		spawn_effect()
	# Suspensión en aire
	if not player.is_on_floor():
		suspended = true
		player.velocity.y = 0
		await get_tree().create_timer(suspend_air_time).timeout
		suspended = false
		player.jump_locked = true  # Bloquear salto tras dash aéreo

	reset_dash_cooldown()

func physics_update(delta: float):
	timer += delta
	player.velocity.x = dash_dir * dash_speed
	player.sprite.visible = false
	if not suspended:
		player.velocity.y += player.GRAVITY

	player.move_and_slide()

	# Desbloquear salto al tocar piso
	if player.is_on_floor():
		player.jump_locked = false

	# Terminar dash
	if timer >= dash_time:
		player.is_dashing = false
		if player.is_on_floor():
			if player.animationPlayer:
				player.animationPlayer.play("Idle")
			emit_signal("finished", "Idle")
		else:
			if player.animationPlayer:
				player.animationPlayer.play("Fall")
			emit_signal("finished", "InAir", {"FromDash": true})

func reset_dash_cooldown():
	await get_tree().create_timer(dash_cooldown).timeout
	player.can_dash = true

func spawn_effect() -> void:
	var effect : Node3D = Node3D.new()
	var num_copies : int = 5
	player.get_parent().add_child( effect )
	effect.global_position = player.global_position - Vector3(1,0,0)
	effect.scale = player.scale
	player.sprite.visible = true
	
	
	var aura_copy : Sprite3D = player.sprite.duplicate(	)
	effect.add_child(aura_copy)
	
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(effect,"modulate", Color(1,1,1,0.0),2)
	tween.chain().tween_callback(effect.queue_free)
