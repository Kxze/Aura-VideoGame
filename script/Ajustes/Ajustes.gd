extends Popup

@onready var click_sound = preload("res://sonidos/botón2.wav")
@onready var popup_ajustes: Popup = self

# Referencias a botones (con null safety)
@onready var btn_cerrar: Button = get_node_or_null("Panel/BtnCerrar")
@onready var btn_continuar: Button = get_node_or_null("Panel/BtnContinuar")
@onready var btn_inicio: Button = get_node_or_null("Panel/BtnInicio")
@onready var btn_salir: Button = get_node_or_null("Panel/BtnSalir")

signal cerrado_por_esc

# origen_actual: "inicio" | "pausa"
var origen_actual: String = "inicio"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var am = get_node_or_null("/root/AudioManager")
	if am:
		# Asegurar que el AudioManager siga corriendo aunque pausemos el árbol
		am.process_mode = Node.PROCESS_MODE_ALWAYS

	# Conectar señales
	if btn_salir: btn_salir.pressed.connect(Callable(self, "_on_btn_salir_pressed"))
	if btn_inicio: btn_inicio.pressed.connect(Callable(self, "_on_btn_inicio_pressed"))
	if btn_cerrar: btn_cerrar.pressed.connect(Callable(self, "_on_btn_cerrar_pressed"))
	if btn_continuar: btn_continuar.pressed.connect(Callable(self, "_on_btn_continuar_pressed"))

	# Detectar apertura/cierre
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))


func mostrar_banners(origen: String) -> void:
	origen_actual = origen
	match origen:
		"inicio":
			if btn_cerrar: btn_cerrar.visible = true
			if btn_inicio: btn_inicio.visible = false
			if btn_salir: btn_salir.visible = false
		"pausa":
			if btn_cerrar: btn_cerrar.visible = false
			if btn_inicio: btn_inicio.visible = true
			if btn_salir: btn_salir.visible = true


# --- LOGICA CRÍTICA DE VISIBILIDAD (AQUÍ ESTABA EL ERROR) ---
func _on_visibility_changed() -> void:
	var am = get_node_or_null("/root/AudioManager")
	
	if visible:
		# 1. Pausar el juego (física, enemigos)
		get_tree().paused = true

		# 2. Avisar al AudioManager (SOLO usamos esta función)
		if am:
			# Esta función ya se encarga de congelar diálogos y mutear efectos
			am.set_ajustes_popup_abierto(true)
			
	else:
		# 1. Reanudar el juego
		get_tree().paused = false

		# 2. Reanudar audio
		if am:
			# Esta función fuerza el des-muteo y la reanudación del diálogo
			am.set_ajustes_popup_abierto(false)
			# NOTA: Borré 'am.set_pausa_activa' para evitar conflictos


# --- BOTONES ---

func _on_btn_cerrar_pressed() -> void:
	_play_click()
	# Al cambiar de escena, reactivamos todo por seguridad
	_reactivar_audio_total()
	popup_ajustes.visible = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_btn_continuar_pressed() -> void:
	_play_click()
	hide() # Esto dispara _on_visibility_changed automáticamente

func _on_btn_inicio_pressed() -> void:
	_play_click()
	_reactivar_audio_total()
	var am = get_node_or_null("/root/AudioManager")
	if am: am.stop_music()
	popup_ajustes.visible = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_btn_salir_pressed() -> void:
	_play_click()
	get_tree().quit()


# --- UTILIDADES ---

func _unhandled_input(event) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			hide()
			# No llamamos a _reactivar_audio_total aquí, hide() ya dispara _on_visibility_changed
			emit_signal("cerrado_por_esc")
			get_viewport().set_input_as_handled()

func _play_click() -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_click(click_sound)

func _reactivar_audio_total() -> void:
	var am = get_node_or_null("/root/AudioManager")
	get_tree().paused = false
	if am:
		am.set_ajustes_popup_abierto(false)
		am.set_pausa_activa(false)

func _on_slider_dialogos_value_changed(value: float) -> void:
	pass
