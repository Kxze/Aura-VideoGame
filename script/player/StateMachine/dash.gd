extends PlayerState
@export var dash_trail_scene: PackedScene # opcional si quieres Node3D base para cada copia
@export var num_copies := 4
@export var fade_time := 1.5
@export var delay_step := 0.05
@export var offset_x := 0.5  # distancia entre copias
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
		spawn_dash_trail()
	# Suspensión en aire
	if not player.is_on_floor():
		suspended = true
		player.velocity.y = 0
		await get_tree().create_timer(suspend_air_time).timeout
		suspended = false
		player.jump_locked = true  # Bloquear salto tras dash aéreo
	player.sprite.visible = false
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

func spawn_dash_trail(num_copies: int = 4) -> void:
	player.sprite.visible = true

	for i in range(num_copies):
		# Instanciar la escena de trail
		var effect = dash_trail_scene.instantiate()
		player.get_parent().add_child(effect)
		
		# Posición inicial con offset
		effect.global_position = player.global_position + Vector3(offset_x * i * player.last_facing, 0, 0)
		effect.scale = player.scale
		effect.target = player  # asignamos el jugador como objetivo
		
		# Duplicar el sprite del jugador dentro de la escena
		var aura_copy: Sprite3D = player.sprite.duplicate(true)
		effect.add_child(aura_copy)
		
		# Flip según orientación
		aura_copy.scale.x = player.last_facing * abs(aura_copy.scale.x)
		
		# Tween para desvanecer
		var tween: Tween = effect.create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_interval(i * delay_step)
		tween.tween_property(effect, "modulate", Color(1,1,1,0), fade_time)
		tween.tween_callback(effect.queue_free)
