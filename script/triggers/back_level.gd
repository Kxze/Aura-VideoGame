extends Area3D
@export var previous_scene : PackedScene

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		get_tree().change_scene_to_packed(previous_scene)
