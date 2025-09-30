extends Control

func _ready():
	# Conectar señales de los botones
	$Panel/flecha_izq.pressed.connect(_on_flecha_izq_pressed)
	$Panel/salir.pressed.connect(_on_salir_pressed)


func _input(event):
	if event.is_action_pressed("ui_left"):  # flecha izquierda
		_on_flecha_izq_pressed()
	elif event.is_action_pressed("ui_cancel"):  # ESC
		_on_salir_pressed()


# --- Funciones para cambiar de escena ---
func _on_flecha_izq_pressed():
	get_tree().change_scene_to_file("res://scenes/coleccionista2.tscn")

func _on_salir_pressed():
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
