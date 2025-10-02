extends PlayerState

var isJumping: bool = false
var canReadJumpCoyote: bool = false
var buffered_jump: bool = false

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var Jump_buffer_timer: Timer = $JumpBufferTimer

func enter(previous_state_path: String, data := {}):
	isJumping = false

	# Saltar solo si viene de comando Jump
	if data.has("Jump"):
		_do_jump()
		player.animationPlayer.play("Jump")

	# Iniciar coyote solo si no viene de Dash
	if not data.has("FromDash"):
		canReadJumpCoyote = true
		coyote_timer.start()

func physics_update(delta: float):
	if player.is_on_floor():
		if buffered_jump and not player.jump_locked and not player.is_dashing:
			buffered_jump = false
			emit_signal("finished", "InAir", {"Jump": true})
		else:
			emit_signal("finished", "Idle")
		player.jump_locked = false
	else:
		# Aplicar gravedad
		player.velocity.y += player.GRAVITY
		if player.velocity.y < 0:
			player.animationPlayer.play("Fall")
		if player.ray_cast_3d.is_colliding():
			player.animationPlayer.play("Land")
		else:
			player.animationPlayer.play("Fall")
	# Movimiento horizontal en el aire
	if !player.is_on_floor():
		player.velocity.x = lerp(player.prevVelocity.x, player.movInput.x, 0.1)

	if player.movInput.x != 0:
		player.velocity.x = player.movInput.x * player.speed

	player.prevVelocity = player.movInput
	player.move_and_slide()
	player.global_position.z = 0


func handled_input(_event: InputEvent):
	# Dash primero
	if Input.is_action_just_pressed("dash") and player.can_dash and not player.is_dashing:
		emit_signal("finished", "Dash")
		return  

	# Salto
	if Input.is_action_just_pressed("ui_accept"):
		if player.jump_locked or player.is_dashing:
			return  
		if player.is_on_floor() or canReadJumpCoyote:
			emit_signal("finished", "InAir", {"Jump": true})
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
	player.animationPlayer.play("Jump")
