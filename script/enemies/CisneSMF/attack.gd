extends CisneState



func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		cisne.animationCisneNegro.play("Ataque")
	




func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		emit_signal("finished","Idle")
