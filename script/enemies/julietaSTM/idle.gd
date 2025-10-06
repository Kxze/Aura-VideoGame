extends Julieta_state

func enter(previous_state_path: String, data := {}):
	# 🔊 Inicia la secuencia continua del llanto (AudioManager alterna clips)
	AudioManager.play_julieta()
	julieta.animationPlayer.play("Ataque")

	# 🧩 Conectar el popup de ajustes (para detener sonido al abrirlo)
	_connect_popup_signals()

	# 🎬 Detener sonido al cambiar de escena (salir del nivel 3)
	if not get_tree().is_connected("scene_changed", Callable(self, "_on_scene_changed")):
		get_tree().connect("scene_changed", Callable(self, "_on_scene_changed"))

# ---------------------------------------------------------
# 🔍 Conectar evento de visibilidad del popup
func _connect_popup_signals():
	var popup_ajustes = _find_popup_ajustes()
	if popup_ajustes and not popup_ajustes.is_connected("visibility_changed", Callable(self, "_on_popup_ajustes_visibility_changed")):
		popup_ajustes.visibility_changed.connect(_on_popup_ajustes_visibility_changed)
		print("✅ Señales conectadas al popup de ajustes.")
	else:
		print("⚠️ No se encontró Popup_Ajustes en esta escena.")

# ---------------------------------------------------------
# 🎚️ Pausar / reanudar llanto según visibilidad del popup
func _on_popup_ajustes_visibility_changed():
	var popup_ajustes = _find_popup_ajustes()
	if not popup_ajustes:
		return

	if popup_ajustes.visible:
		AudioManager.stop_julieta()
		print("🔇 Llanto detenido (popup abierto).")
	elif julieta.animationPlayer.current_animation == "Ataque":
		AudioManager.play_julieta()
		print("💧 Llanto reanudado (popup cerrado).")

# ---------------------------------------------------------
# 🧭 Buscar el popup de ajustes en la jerarquía
func _find_popup_ajustes() -> Popup:
	for node in get_tree().get_nodes_in_group("ajustes_popup"):
		return node
	for root_child in get_tree().root.get_children():
		if root_child.has_node("Popup_Ajustes"):
			return root_child.get_node("Popup_Ajustes")
	return null

# ---------------------------------------------------------



func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		AudioManager.stop_julieta()
		emit_signal("finished","Callada")
