extends PlayerState

# Precarga tus sonidos de pasos
@onready var pasos = [
	preload("res://sonidos/pasos/paso1.mp3"),
	preload("res://sonidos/pasos/paso2.mp3"),
	preload("res://sonidos/pasos/paso3.mp3"),
	preload("res://sonidos/pasos/paso4.mp3"),
	preload("res://sonidos/pasos/paso5.mp3"),
	preload("res://sonidos/pasos/paso6.mp3"),
	preload("res://sonidos/pasos/paso7.mp3"),
	preload("res://sonidos/pasos/paso8.mp3"),
	preload("res://sonidos/pasos/paso9.mp3"),
	preload("res://sonidos/pasos/paso10.mp3"),
]

var step_timer := 0.0
var step_interval := 0.4  # tiempo entre pasos (ajústalo según animación o velocidad)
var isRunning : bool = false

func enter(previous_state_path : String, data := {}):
	player.animationPlayer.play("Walk")
	isRunning = false
	step_timer = 0.0  # reiniciamos el temporizador de pasos

func physics_update(delta: float):
	# --- Si deja de tocar el suelo, cambia a Fall ---
	if not player.is_on_floor():
		player.can_play_steps = false  # 🚫 Desactiva pasos en el aire
		emit_signal("finished", "Fall")
		return

	# --- Si toca el suelo, reactiva pasos ---
	if not player.can_play_steps:
		player.can_play_steps = true  # ✅ Permite pasos otra vez

	# --- Movimiento y animaciones ---
	player.speed = player.speed_normal

	if Input.is_action_pressed("run"):
		isRunning = true
		player.speed = player.speed_run
		if player.animationPlayer.current_animation != "Run":
			player.animationPlayer.play("Run")
	elif player.movInput.x != 0:
		isRunning = false
		if player.animationPlayer.current_animation != "Walk":
			player.animationPlayer.play("Walk")
	else:
		emit_signal("finished", "Idle")

	# --- Sonidos de pasos 👟 ---
	if player.is_on_floor() and player.can_play_steps and player.movInput.x != 0:
		step_timer -= delta
		if step_timer <= 0.0:
			AudioManager.play_random_sfx(pasos)
			# Si está corriendo, que los pasos sean más rápidos
			step_interval = 0.25 if isRunning else 0.4
			step_timer = step_interval
	else:
		step_timer = 0.0

	# --- Jump ---
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.can_play_steps = false  # 🔇 al saltar, desactiva pasos
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

		if target_scale != player.last_facing:
			flip_character(target_scale)
			player.last_facing = target_scale  # actualizamos dirección

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

func accelerate(movInput: Vector2):
	player.velocity = player.velocity.move_toward(player.speed + player.movInput, player.acceleration)

func apply_friction():
	player.velocity = player.velocity.move_toward(Vector3.ZERO, player.friction)

func exit():
	pass
