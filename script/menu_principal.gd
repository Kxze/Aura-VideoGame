extends VBoxContainer

@onready var click_sound = preload("res://sonidos/botón2.wav")   # 🔊 sonido click
@onready var hover_sound = preload("res://sonidos/hover.wav")    # 🔊 sonido hover/desplazamiento

var _buttons = []
var _mouse_mode := false   # 🔄 modo actual (teclado o mouse)

func _ready():

	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager:
		var musica_menu = preload("res://musica/MelodiaMenu.mp3")
		audio_manager.play_music(musica_menu, true)
	else:
		push_warning("No se encontró AudioManager en /root/")

	# Guardamos los botones en una lista
	_buttons = [$Button, $Button2, $Button3, $Button4, $Button5]

	for b in _buttons:
		# Acciones
		if b == $Button:
			b.connect("pressed", Callable(self, "_on_nueva_partida_pressed").bind(b))
		elif b == $Button2:
			b.connect("pressed", Callable(self, "_on_continuar_pressed").bind(b))
		elif b == $Button3:
			b.connect("pressed", Callable(self, "_on_coleccionista_pressed").bind(b))
		elif b == $Button4:
			b.connect("pressed", Callable(self, "_on_ajustes_pressed").bind(b))
		elif b == $Button5:
			b.connect("pressed", Callable(self, "_on_salir_pressed").bind(b))

		# Señales de teclado y mouse
		b.connect("focus_entered", Callable(self, "_on_button_focus_entered").bind(b))
		b.connect("focus_exited", Callable(self, "_on_button_focus_exited").bind(b))
		b.connect("mouse_entered", Callable(self, "_on_button_mouse_entered").bind(b))
		b.connect("mouse_exited", Callable(self, "_on_button_focus_exited").bind(b))

		# Al inicio ocultamos las estrellas y el glow
		_hide_stars(b)

	# --- Focus inicial en el primer botón ---
	if _buttons.size() > 0:
		_buttons[0].grab_focus()
		_on_button_focus_entered(_buttons[0])

# --- Control de input global ---
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_mouse_mode = true  # Se está usando el mouse

	elif event is InputEventKey and event.pressed:
		_mouse_mode = false  # Se está usando el teclado
		# Si ningún botón tiene focus, reasignamos al primero
		var focused_found = false
		for b in _buttons:
			if b.has_focus():
				focused_found = true
				break
		if not focused_found and _buttons.size() > 0:
			_buttons[0].grab_focus()

# --- Acciones de los botones ---
func _on_nueva_partida_pressed(button):
	_play_click()
	AudioManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

#⚠ ⚠ ⚠ ⚠ AHORA ES LA PANTALLA DE CRÉDITOS ⚠ ⚠ ⚠ ⚠
func _on_continuar_pressed(button):
	_play_click()
	print("Continuar partida (cargar juego)")
	get_tree().change_scene_to_file("res://scenes/partidas.tscn")

func _on_coleccionista_pressed(button):
	_play_click()
	print("Abrir coleccionista")
	get_tree().change_scene_to_file("res://scenes/coleccionista.tscn")

func _on_ajustes_pressed(button):
	_play_click()
	UiGlobal.popup_ajustes.mostrar_banners("inicio")
	UiGlobal.popup_ajustes.popup_centered()
	UiGlobal.popup_ajustes.show()

func _on_salir_pressed(button):
	_play_click()
	print("Salir del juego")
	get_tree().quit()

# --- Manejo de estrellas y glow ---
func _on_button_focus_entered(button):
	if not _mouse_mode:
		_play_hover()
		_show_stars(button)

func _on_button_mouse_entered(button):
	_mouse_mode = true
	_play_hover()
	_show_stars(button)
	# Quita el focus de los demás botones
	for b in _buttons:
		if b != button and b.has_focus():
			b.release_focus()

func _on_button_focus_exited(button):
	_hide_stars(button)

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

# --- 🔊 Reproducir sonido ---
func _play_click():
	return AudioManager.play_click(click_sound)

func _play_hover():
	return AudioManager.play_hover(hover_sound)
