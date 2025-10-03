extends VBoxContainer

# --- Sonidos ---
@onready var click_sound = preload("res://sonidos/botón2.wav")   # 🔊 sonido de click
@onready var hover_sound = preload("res://sonidos/hover.wav")    # 🔊 sonido al desplazarse

var _buttons: Array = []
var _current_index := 0  # índice del botón seleccionado

func _ready():
	_buttons = [$Button, $Button2, $Button3, $regresar]

	# Conectar acciones de los botones (click + sonido)
	_buttons[0].pressed.connect(func():
		_play_click()
		_on_noche1_pressed()
	)
	_buttons[1].pressed.connect(func():
		_play_click()
		_on_nueva_partida1_pressed()
	)
	_buttons[2].pressed.connect(func():
		_play_click()
		_on_nueva_partida2_pressed()
	)
	_buttons[3].pressed.connect(func():
		_play_click()
		_on_regresar_pressed()
	)

	# Conectar señales de foco y mouse (hover + sonido)
	for i in range(_buttons.size()):
		var b = _buttons[i]
		b.focus_entered.connect(_on_button_selected.bind(i))
		b.mouse_entered.connect(_on_button_selected.bind(i))
		_hide_stars(b)

	# Activar el primer botón al inicio
	_set_active_button(0)

# --- Acciones de los botones ---
func _on_noche1_pressed():
	print("Cargar Noche 1")
	_play_click()
	get_tree().change_scene_to_file(Constants.scene_levels["level_1"])

func _on_nueva_partida1_pressed():
	print("Crear nueva partida 1")
	_play_click()

func _on_nueva_partida2_pressed():
	print("Crear nueva partida 2")
	_play_click()

func _on_regresar_pressed() -> void:
	print("Regresando al menú principal")
	_play_click()
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
	

# --- Control de teclado ---
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DOWN:
			_current_index = (_current_index + 1) % _buttons.size()
			_set_active_button(_current_index)
		elif event.keycode == KEY_UP:
			_current_index = (_current_index - 1 + _buttons.size()) % _buttons.size()
			_set_active_button(_current_index)
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_buttons[_current_index].emit_signal("pressed")

# --- Selección de botones ---
func _on_button_selected(index: int):
	_set_active_button(index)
	_play_hover()  # 🔊 sonar al moverse con teclado/mouse

func _set_active_button(index: int):
	# Apagar todos
	for b in _buttons:
		_hide_stars(b)

	# Encender solo el seleccionado
	var selected = _buttons[index]
	_show_stars(selected)
	_current_index = index
	selected.grab_focus()

# --- Helpers ---
func _show_stars(button):
	if button.has_node("HBoxContainer/StarLeft"):
		button.get_node("HBoxContainer/StarLeft").visible = true
	if button.has_node("HBoxContainer/StarRight"):
		button.get_node("HBoxContainer/StarRight").visible = true

func _hide_stars(button):
	if button.has_node("HBoxContainer/StarLeft"):
		button.get_node("HBoxContainer/StarLeft").visible = false
	if button.has_node("HBoxContainer/StarRight"):
		button.get_node("HBoxContainer/StarRight").visible = false

# --- 🔊 Reproducir sonidos ---
func _play_click():
	AudioManager.play_click(click_sound)

func _play_hover():
	AudioManager.play_click(hover_sound)
