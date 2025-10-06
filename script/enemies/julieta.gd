extends CharacterBody3D
class_name Julieta

var damage: int = 3


func Make_damage(body):
	Player.health -= damage
	body.animationPlayer.play("Death")
	
	print(Player.health)
	if Player.health <= 0:
		print("jugador ya no tiene vidas...muere")
		if Player.spawnPoint:
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			body.global_position = Player.spawnPoint.global_position
			body.velocity = Vector3.ZERO  # Resetear velocidad
			Player.health = 3
		else:
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			get_tree().reload_current_scene()
			Player.health = 3
		


func _on_zone_damage_body_entered(body: Node3D) -> void:
	if body.name == "Player" and !Player.invencible:
		Make_damage(body)
