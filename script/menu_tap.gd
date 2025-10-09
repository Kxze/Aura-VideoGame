extends Control

func _ready():
	var escena_actual = get_tree().current_scene.name
	

func _unhandled_input(event):
	# --- Detectar teclas ---
	if event is InputEventKey and event.pressed:
		# Ignorar teclas de volumen
		if event.keycode in [KEY_VOLUMEUP, KEY_VOLUMEDOWN]:
			return
		# Aceptar cualquier otra tecla
		_cambiar_a_menu()

	# --- Detectar clic del mouse izquierdo ---
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_cambiar_a_menu()

func _cambiar_a_menu():
	
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
