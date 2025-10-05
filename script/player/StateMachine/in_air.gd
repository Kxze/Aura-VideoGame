extends PlayerState

var isJumping: bool = false
var canReadJumpCoyote: bool = false
var buffered_jump: bool = false
var was_on_floor: bool = false
var did_jump: bool = false   # 👈 indica si vino de un salto

@onready var fall_timer: Timer = $FallTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var Jump_buffer_timer: Timer = $JumpBufferTimer

# 🎵 Sonidos
@onready var jump_sounds = [
	preload("res://sonidos/saltos/jump1.wav"),
	preload("res://sonidos/saltos/jump2.wav"),
	preload("res://sonidos/saltos/jump3.wav")
]

@onready var land_sound = preload("res://sonidos/cae_salto.wav")

func enter(previous_state_path: String, data := {}):
	isJumping = false
	was_on_floor = player.is_on_floor()

	if data.has("Jump"):
		did_jump = true  # 👈 marca que el vuelo viene de salto
		_do_jump()

	if not data.has("FromDash"):
		canReadJumpCoyote = true
		coyote_timer.start()


func physics_update(delta: float):
	player.velocity.y += player.GRAVITY
	player.move_and_slide()

	# --- 🔊 Detectar aterrizaje ---
	if player.is_on_floor() and not was_on_floor:
		if did_jump:
			AudioManager.play_and_get_duration(land_sound)
			did_jump = false

	# --- Actualiza estado de suelo ---
	was_on_floor = player.is_on_floor()

	# --- Control de animaciones y lógica ---
	if player.is_on_floor():
		player.can_play_steps = true

		if buffered_jump and not player.jump_locked and not player.is_dashing:
			buffered_jump = false
			emit_signal("finished", "InAir", {"Jump": true})
		else:
			# 🔊 Mueve el sonido ANTES del cambio de estado
			if did_jump:  
				AudioManager.play_and_get_duration(land_sound)
				did_jump = false
			emit_signal("finished", "Idle")

		player.jump_locked = false
	else:
		player.can_play_steps = false

	if player.velocity.y > 0 and player.animationPlayer.current_animation != "Fall":
		player.animationPlayer.play("Fall")

	if !player.is_on_floor():
		player.velocity.x = lerp(player.prevVelocity.x, player.movInput.x, 0.1)

	if player.movInput.x != 0:
		player.velocity.x = player.movInput.x * player.speed

	player.prevVelocity = player.movInput
	player.global_position.z = 0


func handled_input(_event: InputEvent):
	if Input.is_action_just_pressed("dash") and player.can_dash and not player.is_dashing:
		emit_signal("finished", "Dash")
		return  

	if Input.is_action_just_pressed("ui_accept"):
		if player.jump_locked or player.is_dashing:
			return  
		if player.is_on_floor() or canReadJumpCoyote:
			did_jump = true  # 👈 importante
			emit_signal("finished", "InAir", {"Jump": true})
			player.animationPlayer.play("Jump", 0.0, 1.0, false)
		else:
			buffered_jump = true
			Jump_buffer_timer.start()


func _on_coyote_timer_timeout() -> void:
	canReadJumpCoyote = false

func _on_jump_buffer_timer_timeout() -> void:
	buffered_jump = false


func _do_jump():
	isJumping = true
	player.velocity.y = player.jump
	player.animationPlayer.play("Jump", 0.0, 1.0, false)
	player.can_play_steps = false
	AudioManager.play_random_sfx(jump_sounds)
