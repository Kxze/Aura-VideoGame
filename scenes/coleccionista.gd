extends Control

func _ready():
	# Conectar señales de los botones
	$flecha_der.pressed.connect(_on_flecha_der_pressed)
	$salir.pressed.connect(_on_salir_pressed)


func _input(event):
	# Detectar teclas del teclado
	if event.is_action_pressed("ui_right"):  # flecha derecha
		_on_flecha_der_pressed()
	elif event.is_action_pressed("ui_cancel"):  # ESC
		_on_salir_pressed()


# --- Funciones para cambiar de escena ---
func _on_flecha_der_pressed():
	get_tree().change_scene_to_file("res://scenes/coleccionista2.tscn")

func _on_salir_pressed():
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
