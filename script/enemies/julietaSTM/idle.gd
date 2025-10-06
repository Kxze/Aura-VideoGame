extends Julieta_state

func enter(previous_state_path: String, data := {}):
	# 🔊 Inicia el llanto con variaciones naturales (pitch/volumen)
	AudioManager.play_julieta()
	julieta.animationPlayer.play("Ataque")

	# 🧩 Detectar popup de ajustes (para detener sonido al abrirlo)
	_connect_popup_signals()

	# 🎬 Detener sonido si cambia la escena (al salir del nivel)
	if not get_tree().is_connected("scene_changed", Callable(self, "_on_scene_changed")):
		get_tree().connect("scene_changed", Callable(self, "_on_scene_changed"))

# ---------------------------------------------------------
# 🔍 Conectar evento del popup de ajustes
func _connect_popup_signals():
	var popup_ajustes = _find_popup_ajustes()
	if popup_ajustes and not popup_ajustes.is_connected("visibility_changed", Callable(self, "_on_popup_ajustes_visibility_changed")):
		popup_ajustes.visibility_changed.connect(_on_popup_ajustes_visibility_changed)
		print("✅ Señales conectadas al popup de ajustes.")
	else:
		print("⚠️ No se encontró Popup_Ajustes en esta escena.")

# ---------------------------------------------------------
# 🎚️ Cuando el popup aparece o desaparece
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
# 🧭 Buscar el popup en la jerarquía
func _find_popup_ajustes() -> Popup:
	# Primero por grupo (recomendado)
	for node in get_tree().get_nodes_in_group("ajustes_popup"):
		return node
	# Búsqueda genérica si no está en grupo
	for root_child in get_tree().root.get_children():
		if root_child.has_node("Popup_Ajustes"):
			return root_child.get_node("Popup_Ajustes")
	return null

# ---------------------------------------------------------
# 🏁 Al cambiar de escena, detener el sonido
func _on_scene_changed(new_scene):
	AudioManager.stop_julieta()
	print("🏁 Llanto detenido al salir del nivel.")

# ---------------------------------------------------------
func exit():
	AudioManager.stop_julieta()
	if get_tree().is_connected("scene_changed", Callable(self, "_on_scene_changed")):
		get_tree().disconnect("scene_changed", Callable(self, "_on_scene_changed"))
