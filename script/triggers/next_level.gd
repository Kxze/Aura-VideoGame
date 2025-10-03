extends Area3D

@export var next_level_path: String = ""   # Escena del siguiente nivel
@export var prev_level_path: String = ""   # Escena del nivel anterior
@export var is_next: bool = true           # true = puerta al siguiente, false = puerta al anterior

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		var scene_path = ""
		print("Entre a la puerta")
		
		if is_next and next_level_path != "":
			scene_path = next_level_path
		elif not is_next and prev_level_path != "":
			scene_path = prev_level_path
		
		if scene_path != "":
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			var tree = get_tree()
			var current_scene = tree.get_current_scene()
			
			# Instanciar la nueva
			var new_scene = load(scene_path).instantiate()
			tree.get_root().add_child(new_scene)
			tree.set_current_scene(new_scene)
			
			# Liberar la anterior
			current_scene.queue_free()
