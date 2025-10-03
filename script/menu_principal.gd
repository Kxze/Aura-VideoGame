extends VBoxContainer

@onready var popup_ajustes: Popup = $"../Popup_Ajustes"

var _buttons = []

func _ready():
	#hacer que los ajustes empiecen ocultos
	popup_ajustes.hide()
	
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

	# --- Nuevo: focus inicial en el primer botón ---
	if _buttons.size() > 0:
		_buttons[0].grab_focus()                # ahora ya puedes usar teclado directo
		_on_button_focus_entered(_buttons[0])   # activa glow y estrellas en el primero

# --- Acciones de los botones ---
#func _on_nueva_partida_pressed(button):
func _on_nueva_partida_pressed(button):
	get_tree().change_scene_to_file(Constants.scene_levels["level_1"])

func _on_continuar_pressed(button):
	print("Continuar partida (cargar juego)")
	get_tree().change_scene_to_file("res://scenes/partidas.tscn")

func _on_coleccionista_pressed(button):
	print("Abrir coleccionista")
	get_tree().change_scene_to_file("res://scenes/coleccionista.tscn")

func _on_ajustes_pressed(button):
	$"../Popup_Ajustes".mostrar("inicio")
	popup_ajustes.popup_centered()
	popup_ajustes.show()

func _on_salir_pressed(button):
	print("Salir del juego")
	get_tree().quit()

# --- Manejo de estrellas y glow ---
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
