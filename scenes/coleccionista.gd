extends Control

func _ready():
	# Conectar botones
	$flecha_der.pressed.connect(_on_flecha_der_pressed)
	$salir.pressed.connect(_on_salir_pressed)

func _input(event):
	# Navegar con teclado
	if event.is_action_pressed("ui_right"):  # tecla Flecha Derecha
		get_tree().change_scene_to_file("res://scenes/coleccionista2.tscn")
	elif event.is_action_pressed("ui_cancel"):  # tecla Esc
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# Funciones de botones
func _on_flecha_der_pressed():
	get_tree().change_scene_to_file("res://scenes/coleccionista2.tscn")

func _on_salir_pressed():
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
