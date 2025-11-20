extends Popup

@onready var click_sound = preload("res://sonidos/botón2.wav")
@onready var popup_ajustes: Popup = self

# evitar null instance si el botón no existe en esta escena
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
		am.process_mode = Node.PROCESS_MODE_ALWAYS

	# conectar señales de botones solo si existen
	if btn_salir:
		btn_salir.pressed.connect(Callable(self, "_on_btn_salir_pressed"))
	if btn_inicio:
		btn_inicio.pressed.connect(Callable(self, "_on_btn_inicio_pressed"))
	if btn_cerrar:
		btn_cerrar.pressed.connect(Callable(self, "_on_btn_cerrar_pressed"))
	if btn_continuar:
		btn_continuar.pressed.connect(Callable(self, "_on_btn_continuar_pressed"))

	# detectar apertura/cierre del popup
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))


func mostrar_banners(origen: String) -> void:
	# origen debe ser "inicio" o "pausa"
	origen_actual = origen

	match origen:
		"inicio":
			if btn_cerrar:
				btn_cerrar.visible = true
			if btn_inicio:
				btn_inicio.visible = false
			if btn_salir:
				btn_salir.visible = false
		"pausa":
			if btn_cerrar:
				btn_cerrar.visible = false
			if btn_inicio:
				btn_inicio.visible = true
			if btn_salir:
				btn_salir.visible = true


# botones
func _on_btn_cerrar_pressed() -> void:
	_play_click()
	_reactivar_audio_total()
	popup_ajustes.visible = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")


func _on_btn_continuar_pressed() -> void:
	_play_click()
	hide() # disparará _on_visibility_changed y restablecerá audio/estado


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


func _unhandled_input(event) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			hide()
			_reactivar_audio_total()
			emit_signal("cerrado_por_esc")
			get_viewport().set_input_as_handled()


func _play_click() -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click(click_sound)


func _on_visibility_changed() -> void:
	var am = get_node_or_null("/root/AudioManager")
	if not am:
		# Si no hay AudioManager, solo gestionamos pausa del árbol
		if visible:
			get_tree().paused = true
		else:
			get_tree().paused = false
		return

	if visible:
		# Pausar la escena (física, timers, entrada)
		get_tree().paused = true

		# Indicar al AudioManager que pause SFX y diálogos, mantenga música
		am.pausar_por_ajustes(true)
	else:
		# Reanudar escena
		get_tree().paused = false

		# Indicar al AudioManager que restaure SFX y diálogos
		am.pausar_por_ajustes(false)


func _reactivar_audio_total() -> void:
	var am = get_node_or_null("/root/AudioManager")
	if not am:
		return

	get_tree().paused = false
	# Aseguramos restauración completa por si algo quedó marcado
	am.set_ajustes_popup_abierto(false)
	am.set_pausa_activa(false)
