extends Odil_state

var swansScene = preload("res://scenes/enemies/cisne.tscn")
func enter(previous_state_path : String, data := {}):
	odil.animation.play("Evoque")
	print("spawneando cisnes")
#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	pass
	
#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	pass
#Esta funcion sobreescribe la funcion Input

	
func exit():
	pass
