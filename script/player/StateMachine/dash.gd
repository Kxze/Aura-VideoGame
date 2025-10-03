extends PlayerState
@export var dash_trail_scene: PackedScene # opcional si quieres Node3D base para cada copia
@export var num_copies := 4
@export var fade_time := 5.0       # cuánto tarda en desvanecerse
@export var solid_time := 0.5      # cuánto tiempo queda sólido antes de desvanecer
@export var delay_step := 0.05
@export var offset_x := 0.5  # distancia entre copias
var dash_time := 0.3
var dash_speed := 40
var timer := 0.0
var dash_dir := 1
var suspend_air_time := 0.5
var suspended := false

var dash_cooldown := 0.5

signal dash_started

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
		emit_signal("dash_started")
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
	player.global_position.z = 0
	# Desbloquear salto al tocar piso
	if player.is_on_floor():
		player.jump_locked = false

	# Terminar dash
	if timer >= dash_time:
		player.is_dashing = false
		if player.is_on_floor():
			if player.animationPlayer:
				player.animationPlayer.play("idle")
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
		var effect = dash_trail_scene.instantiate()
		player.get_parent().add_child(effect)
		
		effect.global_position = player.global_position + Vector3(offset_x * i * player.last_facing, 0, 0)
		effect.scale = player.scale
		effect.target = player  

		var aura_copy: Sprite3D = player.sprite.duplicate(true)
		effect.add_child(aura_copy)
		aura_copy.scale.x = player.last_facing * abs(aura_copy.scale.x)
		
		# Tween con tiempo sólido + fade
		var tween: Tween = effect.create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_interval(i * delay_step)                     # escalona las copias
		tween.tween_interval(solid_time)                         # tiempo sólido
		tween.tween_callback(effect.queue_free)
