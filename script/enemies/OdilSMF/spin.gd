extends Odil_state

func enter(previous_state_path : String, data := {}):
	odil.animation.play("Spin")
	odil.isMoving = true
#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	if odil.isHurt:
		emit_signal("finished","Angry")
	
#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	pass
#Esta funcion sobreescribe la funcion Input
func handled_input(_event: InputEvent):
	pass

func exit():
	pass
