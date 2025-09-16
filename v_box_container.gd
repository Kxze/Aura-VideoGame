extends VBoxContainer

var _buttons = []

func _ready():
	# Guardamos los botones en una lista
	_buttons = [$Button, $Button2, $Button3, $Button4, $Button5]

	# Conectamos cada botón a su función de click y focus/mouse
	$Button.connect("pressed", Callable(self, "_on_nueva_partida_pressed"))
	$Button2.connect("pressed", Callable(self, "_on_continuar_pressed"))
	$Button3.connect("pressed", Callable(self, "_on_coleccionista_pressed"))
	$Button4.connect("pressed", Callable(self, "_on_ajustes_pressed"))
	$Button5.connect("pressed", Callable(self, "_on_salir_pressed"))

	for b in _buttons:
		# Teclado
		b.connect("focus_entered", Callable(self, "_on_button_focus_entered").bind(b))
		b.connect("focus_exited", Callable(self, "_on_button_focus_exited").bind(b))
		# Mouse
		b.connect("mouse_entered", Callable(self, "_on_button_focus_entered").bind(b))
		b.connect("mouse_exited", Callable(self, "_on_button_focus_exited").bind(b))
		# Al inicio ocultamos las estrellas
		_hide_stars(b)

# --- Acciones de los botones ---
func _on_nueva_partida_pressed():
	print("Abrir Nueva Partida")
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func _on_continuar_pressed():
	print("Continuar partida (cargar juego)")

func _on_coleccionista_pressed():
	print("Abrir coleccionista")

func _on_ajustes_pressed():
	print("Abrir ajustes")

func _on_salir_pressed():
	print("Salir del juego")
	get_tree().quit()

# --- Manejo de las estrellas ---
func _on_button_focus_entered(button):
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
