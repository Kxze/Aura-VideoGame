extends PlayerState
var isJumping:= false
var canReadJumpCoyote := false
@onready var coyote_timer: Timer = $CoyoteTimer

func enter(previous_state_path: String, data := {}) -> void:
	isJumping = false
	canReadJumpCoyote = false
	
	if data.has("jump"):
		isJumping = true
		player.velocity.y = 0
		player.velocity.y = -player.jumpForce
		player.animation_player.play("jump")
	else: 
		coyote_timer.start()
		canReadJumpCoyote = true
		
func physics_update(delta: float) -> void:
	if player.velocity.y >= 0:
		finished.emit(FALLING)
	else:
		player.velocity.y = -player.jumpForce
	if player.direction.x != 0:
		player.velocity.x = player.direction.x * player.speed

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_up") and canReadJumpCoyote and !player.is_on_floor() and player.velocity.y > 0:
		finished.emit((JUMPING),{"jump" : true})
	if Input.is_action_just_pressed("move_up") and !player.is_on_floor() and player.velocity.y > 0:
		$jumpBufferTimer.start()
	
func update(_delta: float) -> void:
	pass

		


func _on_coyote_timer_timeout() -> void:
	canReadJumpCoyote = false

func _on_jump_buffer_timer_timeout() -> void:
	if $"..".state.name == IDLE or $"..".state.name:
		finished.emit((JUMPING),{"jump" : true}) 
