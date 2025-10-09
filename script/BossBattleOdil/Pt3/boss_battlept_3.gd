extends Node3D
@export var swans_scene : PackedScene
var posible_points1 = Vector3(0.25,0.0,0.0)
var posible_points2 = Vector3(0.0,0.0,0.0)
	
func spawn_swans():
	var instance_swan = swans_scene.instantiate()
	var swan_spawn_location = get_node("SpawnPath/SpawnLocation")
	if $Player.position != posible_points1:
		swan_spawn_location.progress_ratio = .75
	if $Player.position != posible_points2:
		swan_spawn_location.progress_ratio = .25
	
	var player_position = $Player.position
	instance_swan.initialize(swan_spawn_location.position,player_position)
	add_child(instance_swan)



func _on_spawn_timer_timeout() -> void:
	spawn_swans()
