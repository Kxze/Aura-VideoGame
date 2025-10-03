extends VBoxContainer

@onready var ajustes_popup = get_node("/root/MenuPrincipal/Popup_Ajustes")
@onready var click_sound = preload("res://sonidos/botón2.wav")   # 🔊 sonido click
@onready var hover_sound = preload("res://sonidos/hover.wav")    # 🔊 sonido desplazamiento

var _buttons = []

func _ready():
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

		# Teclado
		b.connect("focus_entered", Callable(self, "_on_button_focus_entered").bind(b))
		b.connect("focus_exited", Callable(self, "_on_button_focus_exited").bind(b))

		# Mouse → además de la lógica actual, forzamos el focus
		b.connect("mouse_entered", func():
			b.grab_focus()
			_on_button_focus_entered(b)
		)
		b.connect("mouse_exited", Callable(self, "_on_button_focus_exited").bind(b))

		# Al inicio ocultamos las estrellas y el glow
		_hide_stars(b)

	# --- Nuevo: focus inicial en el primer botón ---
	if _buttons.size() > 0:
		_buttons[0].grab_focus()                # ahora ya puedes usar teclado directo
		_on_button_focus_entered(_buttons[0])   # activa glow y estrellas en el primero

# --- Acciones de los botones ---
func _on_nueva_partida_pressed(button):
	_play_click()
	get_tree().change_scene_to_file(Constants.scene_levels["level_1"])

func _on_continuar_pressed(button) -> void:
	print("Continuar partida (cargar juego)")
	_play_click()
	get_tree().change_scene_to_file("res://scenes/partidas.tscn")
	
func _on_coleccionista_pressed(button):
	_play_click()
	print("Abrir coleccionista")
	get_tree().change_scene_to_file("res://scenes/coleccionista.tscn")

func _on_ajustes_pressed(button):
	_play_click()
	ajustes_popup.popup_centered()
	ajustes_popup.show()

func _on_salir_pressed(button):
	_play_click()
	print("Salir del juego")
	get_tree().quit()

# --- Manejo de estrellas y glow ---
func _on_button_focus_entered(button):
	_play_hover()    # 🔊 aquí suena al mover foco con mouse o teclado
	_show_stars(button)

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

# --- 🔊 Reproducir sonidos ---
func _play_click() -> float:
	return AudioManager.play_click(click_sound)   # ahora siempre devuelve un float

func _play_hover() -> float:
	return AudioManager.play_hover(hover_sound)   # devuelve duración (aunque no lo uses)
