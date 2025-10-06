extends Cascanueces_state

func enter(previous_state_path : String, data := {}):
	cascanueces.animaciones.play("Perseguir")
#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	if !cascanueces.is_on_floor():
		cascanueces.velocity.y += cascanueces.Gravity
	var CurrentLocation = cascanueces.global_transform.origin

	var nextLocation = cascanueces.navAgent.get_next_path_position()

	
	var nextVelocity = (nextLocation - CurrentLocation).normalized() * cascanueces.speed
	var dir_x = (nextLocation - CurrentLocation).normalized().x
	if dir_x > 0:
		cascanueces.pivot.scale = Vector3(-1,1,1)
	else:
		cascanueces.pivot.scale = Vector3(1,1,1)

	
	cascanueces.velocity = cascanueces.velocity.move_toward(nextVelocity, 0.2)
	
	_target_position(cascanueces.Target)
	cascanueces.position.z = 0
	cascanueces.move_and_slide()
	
#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	pass

func exit():
	pass

func _target_position(target):
	cascanueces.navAgent.target_position = cascanueces.Target.global_transform.origin

func _on_estado_alerta_body_exited(body: Node3D) -> void:
	print("El jugador salio del rango de vision")
	emit_signal("finished", "Idle")
	cascanueces.estado.light_color = Color.BEIGE
	cascanueces.time_searching.start()
