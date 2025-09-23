extends PlayerState

#este apartado sobreescribe el estado que viene
func enter(previous_state_path : String, data := {}):
	player.animationPlayer.play("idle")

#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	if !player.is_on_floor():
		emit_signal("finished", "InAir")
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		emit_signal("finished", "InAir", {"Jump" : true})
	
	player.velocity.x = lerpf(player.velocity.x, 0, .9)
	player.move_and_slide()
#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	if player.movInput.x != 0:
		emit_signal("finished","Walking")
		

#Esta funcion sobreescribe la funcion Input
func handled_input(_event: InputEvent):
	pass

func exit():
	pass
