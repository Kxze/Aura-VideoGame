extends PlayerState

@onready var pasos = [
	preload("res://sonidos/pasos/paso2.mp3"),
	preload("res://sonidos/pasos/paso3.mp3"),
	preload("res://sonidos/pasos/paso4.mp3"),
	preload("res://sonidos/pasos/paso5.mp3"),
	preload("res://sonidos/pasos/paso7.mp3"),
	preload("res://sonidos/pasos/paso10.mp3"),
]

var step_timer := 0.0
var step_interval := 0.25  # más rápido que al caminar

@onready var floor_ray: RayCast3D = $"../../RayCast3D"

func enter(previous_state_path : String, data := {}):
	player.lumiere_area.visible = false
	player.animationPlayer.play("Run")
	player.isRunning = true
	step_timer = 0.0
	player.invencible = false


func physics_update(delta: float):
	# ---- Verificar piso ----
	if not player.is_on_floor():
		if floor_ray.is_colliding():
			var floor_distance = player.global_position.y - floor_ray.get_collision_point().y
			if floor_distance > 1.0:
				player.can_play_steps = false
				emit_signal("finished", "Fall")
				return
		else:
			player.can_play_steps = false
			emit_signal("finished", "Fall")
			return

	if not player.can_play_steps:
		player.can_play_steps = true

	# ---- Movimiento base ----
	player.speed = player.speed_run

	if not Input.is_action_pressed("run"):
		emit_signal("finished", "Walk")
	elif player.movInput.x == 0:
		emit_signal("finished", "Idle")

	# ---- Sonido pasos ----
	if player.is_on_floor() and player.can_play_steps and player.movInput.x != 0:
		step_timer -= delta
		if step_timer <= 0.0:
			AudioManager.play_random_sfx(pasos)
			step_timer = step_interval
	else:
		step_timer = 0.0

	# ---- Saltar ----
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.can_play_steps = false
		emit_signal("finished", "InAir", {"Jump" : true})

	# ---- Dash ----
	if Input.is_action_just_pressed("dash") and player.can_dash and not player.is_dashing:
		player.invencible = true
		emit_signal("finished", "Dash")

	if Input.is_action_just_pressed("Lumiere") and player.can_lumiere:
		emit_signal("finished", "Lumiere")

	if player.health <= 0:
		emit_signal("finished", "Dead")

	# ---- Movimiento horizontal ----
	player.velocity.x = lerp(player.velocity.x, player.movInput.x * player.speed, 0.9)
	player.move_and_slide()
	player.global_position.z = 0


func update(_delta: float):
	if player.movInput.x != 0:
		var target_scale = 1 if player.movInput.x > 0 else -1

		if target_scale != player.last_facing:
			flip_character(target_scale)
			player.last_facing = target_scale


func flip_character(target_scale: int):
	var tween = create_tween()

	tween.parallel().tween_property(player.aura, "scale:x", 0, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(player.aura, "scale:y", 1.2, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.tween_property(player.aura, "scale:x", target_scale, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(player.aura, "scale:y", 1, 0.13) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func handled_input(_event: InputEvent):
	pass  # lo gestionamos desde physics_update como en Walk


func exit():
	player.isRunning = false
