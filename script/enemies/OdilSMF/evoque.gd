extends Odil_state

var swan_scene = preload("res://scenes/enemies/cisne.tscn")

@export var safe_distance: float = 10.0     # 🔹 Aumentado para más seguridad
@export var spawn_delay: float = 0.6        # 🔹 Un poco más de tiempo entre cada invocación
@export var ray_length: float = 50.0        # Longitud del raycast
@export var min_spawn_distance_from_center: float = 8.0  # 🔹 Distancia mínima desde el centro del mapa (jugador inicial)

func enter(previous_state_path: String, data := {}):
	odil.animation.play("Evoque")
	print("🕊️ Odil invoca cisnes...")
	spawn_swans_along_path()


func spawn_swans_along_path() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	var spawn_path = odil.get_node_or_null("../SpawnPath")
	if not spawn_path or not player:
		push_warning("⚠️ No se encontró SpawnPath o Player.")
		return

	var curve = spawn_path.curve
	if not curve:
		push_warning("⚠️ El SpawnPath no tiene una curva asignada.")
		return

	var fractions = [0.0, 0.25, 0.5, 0.75, 1.0]
	await spawn_in_sequence(fractions, curve, player)


func spawn_in_sequence(fractions: Array, curve: Curve3D, player: Node3D) -> void:
	await get_tree().create_timer(0.3).timeout  # pequeña pausa inicial

	for f in fractions:
		var spawn_pos = curve.sample_baked(f * curve.get_baked_length())

		# 🚫 Evitar que aparezca cerca del jugador o del centro
		var dist_to_player = player.global_position.distance_to(spawn_pos)
		if dist_to_player < safe_distance or abs(spawn_pos.x) < min_spawn_distance_from_center:
			print("🚫 Punto demasiado cerca del jugador o del centro, omitido:", spawn_pos)
			continue

		# --- RAYCAST HACIA ABAJO PARA AJUSTAR AL SUELO ---
		var space_state = odil.get_world_3d().direct_space_state
		var ray_start = spawn_pos + Vector3(0, 15, 0)
		var ray_end = spawn_pos + Vector3(0, -ray_length, 0)

		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		query.exclude = [odil, player]  # ❗ Evita golpear a Odil o al jugador
		var result = space_state.intersect_ray(query)

		if result.has("position"):
			spawn_pos = result.position
		else:
			print("⚠️ No se encontró suelo bajo este punto, se omite:", spawn_pos)
			continue

		# --- CREAR CISNE ---
		var swan_instance = swan_scene.instantiate()
		get_tree().current_scene.add_child(swan_instance)

		# Posición inicial y escala
		swan_instance.global_position = spawn_pos + Vector3(0, -2, 0)
		swan_instance.scale = Vector3(0.1, 0.1, 0.1)

		# 🔹 Asignar Target inmediatamente
		if swan_instance.has_method("initialize"):
			swan_instance.initialize(spawn_pos, player.global_position)

		# 🔹 Forzar agresividad para que sigan al jugador
		if swan_instance.has_variable("isAgressive"):
			swan_instance.isAgressive = true

		# Efecto de aparición visual
		var tween = create_tween()
		tween.tween_property(swan_instance, "scale", Vector3(1, 1, 1), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(swan_instance, "global_position", spawn_pos, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		await get_tree().create_timer(spawn_delay).timeout

	print("✅ Secuencia de cisnes completada.")


func physics_update(_delta: float) -> void:
	pass

func update(_delta: float) -> void:
	pass

func exit() -> void:
	pass
