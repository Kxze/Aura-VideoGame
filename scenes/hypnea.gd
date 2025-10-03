extends Control

func _ready():
	# Captura cualquier clic dentro del área del Control
	self.gui_input.connect(_on_gui_input)

func _on_gui_input(event):
	# Si es clic izquierdo en cualquier parte de la pantalla
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_cambiar_a_menu()

func _unhandled_input(event):
	# Si se presiona cualquier tecla
	if event is InputEventKey and event.pressed:
		_cambiar_a_menu()

func _cambiar_a_menu():
	get_tree().change_scene_to_file("res://scenes/menu_tap.tscn")
