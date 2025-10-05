extends CheckButton

@onready var click_sound = preload("res://sonidos/botón2.wav")

#si el botón está activado, el juego está en modo pantalla completa, si no, en ventana
func _toggled(toggled_on: bool) -> void:
	_play_click()
	if toggled_on == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _play_click():
	return AudioManager.play_click(click_sound)
