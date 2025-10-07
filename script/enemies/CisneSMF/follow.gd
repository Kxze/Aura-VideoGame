extends CisneState

#este apartado sobreescribe el estado que viene
func enter(previous_state_path : String, data := {}):
	cisne.animationCisneNegro.play("Caminar")

#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	var CurrentLocation = cisne.global_transform.origin
	var nextLocation = cisne.navAgent.get_next_path_position()
#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	pass


func _on_alert_zone_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		emit_signal("finished","Idle")
