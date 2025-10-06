extends Control

# Música exclusiva del menú (menu_tap y menu_principal)
@onready var musica_menu_principal = preload("res://musica/MelodiaMenu.mp3")
# Música general que suena en los niveles
@onready var musica_general = preload("res://musica/MelodiaPrincipal.mp3")

func _ready():
	var escena_actual = get_tree().current_scene.name
	
	# Forzar cambio de música al entrar al menú principal o menú tap
	if escena_actual in ["menu_principal", "menu_tap"]:
		if AudioManager.musica_player.stream != musica_menu_principal:
			AudioManager.musica_player.stop() # 🔥 Detiene lo que estuviera sonando
			AudioManager.play_music(musica_menu_principal, true)
	else:
		# En cualquier otro nivel → reproducir música general
		if AudioManager.musica_player.stream != musica_general:
			AudioManager.musica_player.stop()
			AudioManager.play_music(musica_general, true)

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
	# 🔊 Forzar cambio a la música del menú principal ANTES de cambiar de escena
	if AudioManager.musica_player.stream != musica_menu_principal:
		AudioManager.musica_player.stop()
		AudioManager.play_music(musica_menu_principal, true)
	
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
