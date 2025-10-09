extends Odil_state

func enter(previous_state_path : String, data := {}):
	odil.animation.play("Idle")
#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	if odil.isMoving:
		emit_signal("finished","Spin")
	if odil.isHurt:
		odil.isMoving = false
		emit_signal("finished","Angry")
	if odil.odilFase3:
		emit_signal("finished","Evoque")

	
#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	pass
#Esta funcion sobreescribe la funcion Input


func exit():
	pass
