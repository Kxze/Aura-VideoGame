extends Popup

@onready var click_sound = preload("res://sonidos/botón2.wav")
@onready var popup_ajustes: Popup = $"."
@onready var btn_cerrar: Button = $Panel/BtnCerrar
@onready var btn_continuar: Button = $Panel/BtnContinuar
@onready var btn_inicio: Button = $Panel/BtnInicio
@onready var btn_salir: Button = $Panel/BtnSalir

signal cerrado_por_esc

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Asegura que el AudioManager siga procesando aunque el juego esté pausado
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.process_mode = Node.PROCESS_MODE_ALWAYS

	# Conectar señales de botones
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	btn_inicio.pressed.connect(_on_btn_inicio_pressed)
	btn_continuar.pressed.connect(_on_btn_continuar_pressed)
	btn_cerrar.pressed.connect(_on_btn_cerrar_pressed)


# ---------------------------------------------------------
# 🎛️ Mostrar los botones según el contexto
# ---------------------------------------------------------
func mostrar_banners(origen: String):
	match origen:
		"inicio":
			btn_cerrar.visible = true
			btn_continuar.visible = false
			btn_inicio.visible = false
			btn_salir.visible = false
		"pausa":
			btn_cerrar.visible = false
			btn_continuar.visible = true
			btn_inicio.visible = true
			btn_salir.visible = true


# ---------------------------------------------------------
# 🧭 BOTONES
# ---------------------------------------------------------
func _on_btn_cerrar_pressed() -> void:
	_play_click()
	popup_ajustes.visible = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_btn_continuar_pressed() -> void:
	_play_click()
	_reanudar_audio_y_juego()

	if has_node("/root/UiGlobal"):
		get_node("/root/UiGlobal").cerrar_ajustes()
	else:
		hide()

func _on_btn_inicio_pressed() -> void:
	_play_click()
	_reanudar_audio_y_juego()
	popup_ajustes.visible = false
	AudioManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_btn_salir_pressed() -> void:
	_play_click()
	get_tree().quit()


# ---------------------------------------------------------
# ⌨️ ESC para cerrar
# ---------------------------------------------------------
func _unhandled_input(event):
	if visible and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_reanudar_audio_y_juego()
			hide()
			emit_signal("cerrado_por_esc")
			get_viewport().set_input_as_handled()


# ---------------------------------------------------------
# 🔊 SONIDO DE CLIC
# ---------------------------------------------------------
func _play_click():
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click(click_sound)
	else:
		print("⚠️ No se encontró el AudioManager en el árbol.")


# ---------------------------------------------------------
# 🎮 CONTROL DE PAUSA Y AUDIO
# ---------------------------------------------------------
func _reanudar_audio_y_juego():
	get_tree().paused = false
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.set_pausa_activa(false)  # ▶️ Reanudar diálogos si estaban pausados

func _on_about_to_show() -> void:
	# Este callback se ejecuta automáticamente al abrir el popup
	get_tree().paused = true
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.set_pausa_activa(true)  # ⏸️ Pausar diálogos
