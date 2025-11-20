extends GridContainer

@onready var click_sound = preload("res://sonidos/botón2.wav")
# para el modo de pantalla y resolución
@onready var check_btn: CheckButton = $CheckModo
@onready var option_res: OptionButton = $OptionRES
@onready var popup_ajustes: Popup = $"../../.."

# para los buses de audio
var master_bus: int
var musica_bus: int
var efectos_bus: int
var dialogos_bus: int

# para el modo de pantalla y resolución
var prev_selected: int = -1  # guardará la opción previa

func _ready() -> void:
	# buscar índices de buses (si no existen, se guarda -1)
	master_bus = AudioServer.get_bus_index("Master")
	musica_bus = AudioServer.get_bus_index("Musica")
	efectos_bus = AudioServer.get_bus_index("Efectos")
	dialogos_bus = AudioServer.get_bus_index("Dialogos")

	# comprobar disponibilidad de buses
	if master_bus == -1:
		push_warning("Bus 'Master' no encontrado.")
	if musica_bus == -1:
		push_warning("Bus 'Musica' no encontrado.")
	if efectos_bus == -1:
		push_warning("Bus 'Efectos' no encontrado.")
	if dialogos_bus == -1:
		push_warning("Bus 'Dialogos' no encontrado. El slider de diálogos no funcionará hasta que lo crees.")

	# conexiones UI
	check_btn.toggled.connect(_on_check_btn_toggled)
	option_res.item_selected.connect(_on_option_res_item_selected)

	# Inicializar sliders con valores actuales de los buses (si existen)
	var slider_master = get_node_or_null("SliderVG")
	var slider_musica = get_node_or_null("SliderM")
	var slider_sfx = get_node_or_null("SliderSFX")
	var slider_dialogos = get_node_or_null("SliderDialogos") # asegúrate del nombre del nodo

	if slider_master and master_bus != -1:
		slider_master.value = AudioServer.get_bus_volume_db(master_bus)
	if slider_musica and musica_bus != -1:
		slider_musica.value = AudioServer.get_bus_volume_db(musica_bus)
	if slider_sfx and efectos_bus != -1:
		slider_sfx.value = AudioServer.get_bus_volume_db(efectos_bus)

	if dialogos_bus != -1:
		slider_dialogos.value = AudioServer.get_bus_volume_db(dialogos_bus)

		# ver si ya estaba conectado y si sí, desconectar
		var call = Callable(self, "_on_slider_dialogos_value_changed")

		if slider_dialogos.is_connected("value_changed", call):
			slider_dialogos.disconnect("value_changed", call)

		slider_dialogos.value_changed.connect(call)
	else:
		push_warning("SliderDialogos presente pero no se encontró el bus 'Dialogos'.")



func _on_check_btn_toggled(pressed: bool) -> void:
	_play_click()
	if pressed:
		# Guardar la opción actual antes de desactivar
		prev_selected = option_res.selected
		option_res.disabled = true
	else:
		# Volver a habilitar y restaurar la opción previa
		option_res.disabled = false
		if prev_selected >= 0:
			option_res.select(prev_selected)
			# Simula que el usuario eligió la opción
			option_res.emit_signal("item_selected", prev_selected)

# cambiar resolución según el index
func _on_option_res_item_selected(index: int) -> void:
	match index:
		2:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		0:
			DisplayServer.window_set_size(Vector2i(1152, 648))

## los siguientes son los sliders de VOLUMEN
func _on_slider_vg_value_changed(value: float) -> void:
	if master_bus == -1:
		return
	AudioServer.set_bus_volume_db(master_bus, value)
	AudioServer.set_bus_mute(master_bus, value == -30)

func _on_slider_m_value_changed(value: float) -> void:
	if musica_bus == -1:
		return
	AudioServer.set_bus_volume_db(musica_bus, value)
	AudioServer.set_bus_mute(musica_bus, value == -30)

func _on_slider_sfx_value_changed(value: float) -> void:
	if efectos_bus == -1:
		return
	AudioServer.set_bus_volume_db(efectos_bus, value)
	AudioServer.set_bus_mute(efectos_bus, value == -30)

# nuevo: slider de diálogos
func _on_slider_dialogos_value_changed(value: float) -> void:
	if dialogos_bus == -1:
		return
	AudioServer.set_bus_volume_db(dialogos_bus, value)
	AudioServer.set_bus_mute(dialogos_bus, value == -30)

func _play_click():
	return AudioManager.play_click(click_sound)

func _on_btn_collect_pressed() -> void:
	popup_ajustes.hide()
	get_tree().change_scene_to_file("res://scenes/coleccionista.tscn")
