extends Control

func _ready():
	# Escucha cualquier input dentro de este Control (ocupa toda la pantalla)
	self.gui_input.connect(_on_gui_input)

func _on_gui_input(event):
	# Detecta clic izquierdo (button_index = 1)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_cambiar_a_menu()

	# Si presionas cualquier tecla también cambia
	if event is InputEventKey and event.pressed:
		_cambiar_a_menu()

func _cambiar_a_menu():
	get_tree().change_scene_to_file("res://scenes/menu_tap.tscn")
