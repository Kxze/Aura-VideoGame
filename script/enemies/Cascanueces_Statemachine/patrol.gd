extends Cascanueces_state

func enter(previous_state_path : String, data := {}):
	cascanueces.animaciones.play("Caminado")
#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	if cascanueces.time_searching.is_stopped():
		emit_signal("finished", "Idle")
	
#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	pass
#Esta funcion sobreescribe la funcion Input
func handled_input(_event: InputEvent):
	pass

func exit():
	pass
