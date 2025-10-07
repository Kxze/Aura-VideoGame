extends CisneState

#este apartado sobreescribe el estado que viene
func enter(previous_state_path : String, data := {}):
	cisne.animationCisneNegro.play("Caminar")

#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	var CurrentLocation = cisne.global_transform.origin
	var nextLocation = cisne.navAgent.get_next_path_position()
	
	var nextVelocity = (nextLocation - CurrentLocation).normalized() * cisne.speed
	var dir_x = (nextLocation - CurrentLocation).normalized().x
	if dir_x > 0:
		cisne.pivot.scale = Vector3(-1,1,1)
	else:
		cisne.pivot.scale = Vector3(1,1,1)

	
	cisne.velocity = cisne.velocity.move_toward(nextVelocity, 0.2)
	
	_target_position(cisne.Target)
	cisne.position.z = 0
	cisne.move_and_slide()
#Esta funcion sobreescribe la funcion process

func _target_position(target):
	cisne.navAgent.target_position = cisne.Target.global_transform.origin

func _on_alert_zone_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		emit_signal("finished","Idle")
