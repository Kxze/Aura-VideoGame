extends Node3D
@export var swans_scene : PackedScene

func spawn_swans():
	var instance_swan = swans_scene.instantiate()
	var swan_spawn_location = get_node("SpawnPath/SpawnLocation")
	swan_spawn_location.progress_ratio = randf()
	
	var player_position = $Player.position
	instance_swan.initialize(swan_spawn_location.position,player_position)
	add_child(instance_swan)



func _on_spawn_timer_timeout() -> void:
	spawn_swans()
