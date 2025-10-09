extends CisneState

#este apartado sobreescribe el estado que viene
func enter(previous_state_path : String, data := {}):
	cisne.animationCisneNegro.play("Idle")

#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	if not cisne.Target:
		return
	var distance = cisne.global_position.distance_to(cisne.Target.global_position)
	
	if distance < cisne.distance_alert:
		emit_signal("finished","Follow")

#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	pass

#Esta funcion sobreescribe la funcion Input
func handled_input(_event: InputEvent):
	pass

func exit():
	pass
