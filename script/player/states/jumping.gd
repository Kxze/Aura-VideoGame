extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
		player.animation_player.play("jump")
		player.velocity.y = player.jumpForce
func physics_update(delta: float) -> void:
	
	var input_direction_x := Input.get_axis("move_left", "move_right")
	player.velocity.x = player.speed * input_direction_x
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
		
	if player.velocity.y >= 0:
		finished.emit(FALLING)


		
