extends Cascanueces_state

func enter(previous_state_path : String, data := {}):
	cascanueces.animaciones.play("Ataque")
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


func _on_espada_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		if cascanueces.animaciones.animation_finished():
			cascanueces.Make_damage(body)
