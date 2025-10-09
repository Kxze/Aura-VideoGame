extends CisneState

#este apartado sobreescribe el estado que viene
func enter(previous_state_path : String, data := {}):
	cisne.animationCisneNegro.play("Caminar")
	
#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	if not cisne.Target or not cisne.navAgent:
		emit_signal("finished","Idle")
	if cisne.isAgressive:
		var distancia = cisne.global_position.distance_to(cisne.Target.global_position)
		
		if distancia > cisne.max_distance_from_player:
			emit_signal("finished", "Idle")
		
		cisne.navAgent.target_position = cisne.Target.global_position
		
		var next_point = cisne.navAgent.get_next_path_position()
		var direction = (next_point - cisne.global_position).normalized()
		
		cisne.velocity = direction * cisne.speed
		
		cisne.move_and_slide()
	else:
		emit_signal("finished","Convert")
	
