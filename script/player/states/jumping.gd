extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	jump()
	player.animation_player.play("jump")
	if player.jump_Buffer:
		jump()
		player.jump_Buffer = false
		
	else:
		player.jump_Buffer = true
		get_tree().create_timer(player.jump_Buffer_Time).timeout.connect(on_jump_buffer_timeout)
func physics_update(delta: float) -> void:
	
	var input_direction_x := Input.get_axis("move_left", "move_right")
	player.velocity.x = player.speed * input_direction_x
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	if player.was_on_floor && !player.is_on_floor():
		player.coyote_timer.start()
		
	if player.velocity.y >= 0:
		finished.emit(FALLING)

func jump()->void:
		player.velocity.y = player.jumpForce
		
func on_jump_buffer_timeout()->void:
	player.jump_Buffer = false
