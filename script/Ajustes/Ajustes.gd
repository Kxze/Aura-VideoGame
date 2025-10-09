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
	
	# Mantener el AudioManager activo aunque el juego esté pausado
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.process_mode = Node.PROCESS_MODE_ALWAYS

	# Conectar señales de botones
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	btn_inicio.pressed.connect(_on_btn_inicio_pressed)
	btn_cerrar.pressed.connect(_on_btn_cerrar_pressed)

	# Detectar apertura/cierre del popup para pausar o reanudar audio
	visibility_changed.connect(_on_visibility_changed)


# ---------------------------------------------------------
# 🎛️ Mostrar los botones según el contexto
# ---------------------------------------------------------
func mostrar_banners(origen: String):
	match origen:
		"inicio":
			btn_cerrar.visible = true
	
			btn_inicio.visible = false
			btn_salir.visible = false
		"pausa":
			btn_cerrar.visible = false
			btn_inicio.visible = true
			btn_salir.visible = true


# ---------------------------------------------------------
# 🧭 BOTONES
# ---------------------------------------------------------

func _on_btn_cerrar_pressed() -> void:
	_play_click()
	_reactivar_audio_total()
	popup_ajustes.visible = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")


func _on_btn_inicio_pressed() -> void:
	_play_click()
	_reactivar_audio_total()
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.stop_music()
	popup_ajustes.visible = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_btn_salir_pressed() -> void:
	_play_click()
	_reactivar_audio_total()
	get_tree().quit()


# ---------------------------------------------------------
# ⌨️ ESC para cerrar
# ---------------------------------------------------------
func _unhandled_input(event):
	if visible and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			hide()
			_reactivar_audio_total()
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
# 🎚️ DETECTAR ESTADO DEL POPUP → PAUSAR/REANUDAR AUDIO
# ---------------------------------------------------------
func _on_visibility_changed() -> void:
	var am = get_node_or_null("/root/AudioManager")
	if not am:
		return

	if visible:
		get_tree().paused = true
		am.set_ajustes_popup_abierto(true)
		print("⚙️ Popup de ajustes abierto → audio pausado.")
	else:
		get_tree().paused = false
		am.set_ajustes_popup_abierto(false)
		print("⚙️ Popup de ajustes cerrado → audio reanudado.")


# ---------------------------------------------------------
# 🩵 REACTIVAR TODO EL AUDIO AL SALIR AL MENÚ O CERRAR POPUP
# ---------------------------------------------------------
func _reactivar_audio_total() -> void:
	var am = get_node_or_null("/root/AudioManager")
	if not am:
		return

	get_tree().paused = false
	am.set_ajustes_popup_abierto(false)
	print("🔊 Audio restaurado completamente tras cerrar o cambiar de escena.")
