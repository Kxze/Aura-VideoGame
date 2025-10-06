extends Julieta_state

@onready var julieta_sound = preload("res://sonidos/julieta.ogg")

func enter(previous_state_path : String, data := {}):
	# 🔊 Inicia el llanto en loop al entrar al estado
	AudioManager.play_julieta(julieta_sound)
	julieta.animationPlayer.play("Ataque")

	# 🧩 Intentar encontrar el Popup de ajustes (busca en toda la escena)
	_connect_popup_signals()

	# 🎬 Escuchar cambio de escena (para detener el sonido al salir del nivel)
	if not get_tree().is_connected("scene_changed", Callable(self, "_on_scene_changed")):
		get_tree().connect("scene_changed", Callable(self, "_on_scene_changed"))

# ---------------------------------------------------------
# 🔍 Buscar el popup dinámicamente y conectar las señales
func _connect_popup_signals():
	var popup_ajustes = _find_popup_ajustes()
	if popup_ajustes:
		if not popup_ajustes.is_connected("visibility_changed", Callable(self, "_on_popup_ajustes_visibility_changed")):
			popup_ajustes.visibility_changed.connect(_on_popup_ajustes_visibility_changed)
		print("✅ Señales conectadas al popup de ajustes.")
	else:
		print("⚠️ No se encontró Popup_Ajustes en esta escena.")

# ---------------------------------------------------------
# Detecta apertura o cierre del popup según su visibilidad
func _on_popup_ajustes_visibility_changed():
	var popup_ajustes = _find_popup_ajustes()
	if not popup_ajustes:
		return

	if popup_ajustes.visible:
		# 🛑 Si se muestra, detener el llanto
		AudioManager.stop_julieta()
		print("🔇 Llanto detenido (popup abierto).")
	else:
		# 💧 Si se oculta, reanudar si Julieta sigue activa
		if julieta.animationPlayer.current_animation == "Ataque":
			AudioManager.play_julieta(julieta_sound)
			print("💧 Llanto reanudado (popup cerrado).")

# Busca el popup en toda la jerarquía
func _find_popup_ajustes() -> Popup:
	for node in get_tree().get_nodes_in_group("ajustes_popup"):
		return node
	# Si no está en un grupo, buscar por nombre
	for node in get_tree().get_nodes_in_group("CanvasLayer"):
		if node.has_node("Popup_Ajustes"):
			return node.get_node("Popup_Ajustes")
	# Búsqueda genérica por nombre
	for n in get_tree().root.get_children():
		if n.has_node("Popup_Ajustes"):
			return n.get_node("Popup_Ajustes")
	return null

# ---------------------------------------------------------
# Cuando el popup se abre → detener el sonido de Julieta
func _on_popup_ajustes_opened():
	AudioManager.stop_julieta()
	print("🔇 Llanto detenido al abrir ajustes.")

# Cuando el popup se cierra → reanudar (opcional)
func _on_popup_ajustes_closed():
	if julieta.animationPlayer.current_animation == "Ataque":
		AudioManager.play_julieta(julieta_sound)
		print("💧 Llanto reanudado al cerrar ajustes.")

# ---------------------------------------------------------
# Cuando se cambia de escena → detener el sonido
func _on_scene_changed(new_scene):
	AudioManager.stop_julieta()
	print("🏁 Llanto detenido al salir del nivel.")

# ---------------------------------------------------------
func physics_update(delta: float):
	pass

func update(_delta: float):
	pass

func handled_input(_event: InputEvent):
	pass

# ---------------------------------------------------------
func exit():
	AudioManager.stop_julieta()
	if get_tree().is_connected("scene_changed", Callable(self, "_on_scene_changed")):
		get_tree().disconnect("scene_changed", Callable(self, "_on_scene_changed"))
