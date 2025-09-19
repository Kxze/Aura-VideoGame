extends PlayerState
#este apartado sobreescribe el estado que viene
func enter(previous_state_path : String, data := {}):
	pass

#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	pass

#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	pass

#Esta funcion sobreescribe la funcion Input
func handled_input(_event: InputEvent):
	pass

func exit():
	pass
