extends CheckButton

#si el botón está activado, el juego está en modo pantalla completa, si no, en ventana
func _toggled(toggled_on: bool) -> void:
	if toggled_on == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
