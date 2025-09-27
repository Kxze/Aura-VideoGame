extends Area3D
signal change_level

func _on_puerta_body_entered(body: Node3D) -> void:
	if body == CharacterBody3D:
		emit_signal("change_level")
