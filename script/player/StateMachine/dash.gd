extends PlayerState

@export var dash_trail_scene: PackedScene 
@export var num_copies := 4
@export var fade_time := 5.0
@export var solid_time := 0.5
@export var delay_step := 0.05
@export var offset_x := 0.5
var dash_time := 0.3
var dash_speed := 50
var timer := 0.0
var dash_dir := 1
var suspend_air_time := 0.5
var suspended := false
var cooldown_running := false
var dash_cooldown := 1

signal dash_charged
signal dash_started
signal dash_finished

@onready var dash_sfx = preload("res://sonidos/dash.mp3")
@onready var dash_recargado_sfx = preload("res://sonidos/dash_recargado.wav")

func enter(previous_state_path: String, data := {}):
	if player.is_dashing or not player.can_dash or cooldown_running:
		emit_signal("finished", "Idle")
		return

	player.lumiere_area.visible = false
	player.is_dashing = true
	player.can_dash = false
	timer = 0.0
	dash_dir = player.last_facing

	if player.animationPlayer:
		player.animationPlayer.play("Dash")
	AudioManager.play_and_get_duration(dash_sfx)
	spawn_dash_trail()

	if not player.is_on_floor():
		suspended = true
		player.velocity.y = 0
		await get_tree().create_timer(suspend_air_time).timeout
		suspended = false
		player.jump_locked = true 

	player.sprite.visible = false

	_reset_dash_cooldown()

func physics_update(delta: float):
	timer += delta
	player.velocity.x = dash_dir * dash_speed
	player.sprite.visible = false
	if not suspended:
		player.velocity.y += player.GRAVITY

	player.move_and_slide()
	player.global_position.z = 0
	
	if player.is_on_floor():
		player.jump_locked = false

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

func _reset_dash_cooldown() -> void:
	if cooldown_running:
		return
	cooldown_running = true
	
	# Espera el tiempo de cooldown
	await get_tree().create_timer(dash_cooldown).timeout
	
	# Una vez termina la espera:
	player.can_dash = true
	cooldown_running = false
	
	# Usamos tu AudioManager igual que arriba
	if AudioManager:
		AudioManager.play_and_get_duration(dash_recargado_sfx)
	
	emit_signal("dash_charged")
	emit_signal("dash_finished")

func spawn_dash_trail(num_copies: int = 4) -> void:
	emit_signal("dash_started")
	player.sprite.visible = true
	player.dash_particle.emitting = true
	for i in range(num_copies):
		var effect = dash_trail_scene.instantiate()
		player.get_parent().add_child(effect)
		
		effect.global_position = player.global_position + Vector3(offset_x * i * player.last_facing, 0, 0)
		effect.scale = player.scale
		effect.target = player  

		var aura_copy: Sprite3D = player.sprite.duplicate(true)
		effect.add_child(aura_copy)
		aura_copy.scale.x = player.last_facing * abs(aura_copy.scale.x)
		
		var tween: Tween = effect.create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_interval(i * delay_step)
		tween.tween_interval(solid_time)
		tween.tween_callback(effect.queue_free)
