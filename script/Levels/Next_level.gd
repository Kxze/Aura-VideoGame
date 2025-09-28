extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body == Player:
		get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
