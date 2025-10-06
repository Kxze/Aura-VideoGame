extends Cascanueces_state

func enter(previous_state_path : String, data := {}):
	cascanueces.animaciones.play("Idle")
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


func _on_estado_alerta_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		emit_signal("finished", "Follow")
		cascanueces.estado.light_color = Color(0.798,0.479,0.348)
		print("Jugador detectado, comenzando a perseguirlo")
		


func _on_area_ataque_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		emit_signal("finished","Attack")
