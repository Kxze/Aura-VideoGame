extends PlayerState

var isJumping: bool = false
var canReadJumpCoyote: bool = false
var buffered_jump: bool = false

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var Jump_buffer_timer: Timer = $JumpBufferTimer

var last_facing := 1 

func enter(previous_state_path : String, data := {}):
	isJumping = false
	canReadJumpCoyote = false
	
	if data.has("Jump"):
		_do_jump()
	else:
		coyote_timer.start()
		canReadJumpCoyote = true
		player.animationPlayer.play("Fall")


func physics_update(delta: float):
	if player.is_on_floor():
		if buffered_jump: # Consumir buffer al aterrizar
			buffered_jump = false
			emit_signal("finished", "InAir", {"Jump" : true})
		else:
			emit_signal("finished", "Idle")
	else:
		player.velocity.y += player.GRAVITY

	if player.movInput.x != 0:
		player.velocity.x = player.movInput.x * player.speed

	player.move_and_slide()


func handled_input(_event: InputEvent):
	# Salto
	if Input.is_action_just_pressed("ui_accept"):
		if player.is_on_floor() or canReadJumpCoyote:
			emit_signal("finished", "InAir", {"Jump" : true})
		else:
			buffered_jump = true
			Jump_buffer_timer.start()

	# Dash (en aire o en piso)
	if Input.is_action_just_pressed("dash"): # Asegúrate de mapear "dash" a la tecla E en InputMap
		emit_signal("finished", "Dash") # Esto cambia al estado Dash directamente


func _on_coyote_timer_timeout() -> void:
	canReadJumpCoyote = false

func _on_jump_buffer_timer_timeout() -> void:
	buffered_jump = false


# Función de salto real
func _do_jump():
	isJumping = true
	player.velocity.y = player.jump
	player.animationPlayer.play("jump")
