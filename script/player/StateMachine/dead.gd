extends PlayerState


#este apartado sobreescribe el estado que viene
func enter(previous_state_path : String, data := {}):
	player.animationPlayer.play("Dead")
#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	if player.health <= 0:
		player.animationPlayer.play("Dead")
		


func update(_delta:float):
	pass
#Esta funcion sobreescribe la funcion Input
func handled_input(_event: InputEvent):
	pass

func exit():
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	emit_signal("finished","Idle")
