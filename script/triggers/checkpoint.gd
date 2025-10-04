extends Area3D

@export var checkpoint_marker: Marker3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		Player.spawnPoint = checkpoint_marker
		print("Nuevo checkpoint establecido en:", checkpoint_marker.global_position)
