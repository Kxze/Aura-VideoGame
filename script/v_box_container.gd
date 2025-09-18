extends VBoxContainer

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

		# Teclado y mouse
		b.connect("focus_entered", Callable(self, "_on_button_focus_entered").bind(b))
		b.connect("focus_exited", Callable(self, "_on_button_focus_exited").bind(b))
		b.connect("mouse_entered", Callable(self, "_on_button_focus_entered").bind(b))
		b.connect("mouse_exited", Callable(self, "_on_button_focus_exited").bind(b))

		# Al inicio ocultamos las estrellas y el glow
		_hide_stars(b)
		_enable_glow(b, false)

# --- Acciones de los botones ---
func _on_nueva_partida_pressed(button):
	print("Abrir Nueva Partida")
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func _on_continuar_pressed(button):
	print("Continuar partida (cargar juego)")
	get_tree().change_scene_to_file("res://scenes/partidas.tscn")

func _on_coleccionista_pressed(button):
	print("Abrir coleccionista")
	get_tree().change_scene_to_file("res://scenes/coleccionista.tscn")

func _on_ajustes_pressed(button):
	print("Abrir ajustes")

func _on_salir_pressed(button):
	print("Salir del juego")
	get_tree().quit()

# --- Manejo de estrellas y glow ---
func _on_button_focus_entered(button):
	_show_stars(button)
	_enable_glow(button, true)

func _on_button_focus_exited(button):
	_hide_stars(button)
	_enable_glow(button, false)

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

# --- Glow del shader ---
func _enable_glow(button, enabled: bool):
	if button.material and button.material is ShaderMaterial:
		button.material.set_shader_parameter("active", enabled)
