extends Control

@onready var click_sound = preload("res://sonidos/botón2.wav")
@onready var sonido_cambio_pagina = preload("res://sonidos/cambioPagina.wav")

func _ready():
	# Conectar botones
	$flecha_der.pressed.connect(_on_flecha_der_pressed)
	$salir.pressed.connect(_on_salir_pressed)

func _input(event):
	if event.is_action_pressed("ui_right"):  # Flecha Derecha
		_play_click()
		_play_cambio_pagina_y_cambiar("res://scenes/coleccionista2.tscn")

	elif event.is_action_pressed("ui_cancel"):  # Esc
		_play_click()
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# --- Botones ---
func _on_flecha_der_pressed():
	_play_click()
	_play_cambio_pagina_y_cambiar("res://scenes/coleccionista2.tscn")

func _on_salir_pressed():
	_play_click()
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# --- 🔊 Reproducir sonido ---
func _play_click():
	if AudioManager:
		AudioManager.play_click(click_sound)

func _play_cambio_pagina_y_cambiar(scene_path: String):
	if AudioManager:
		# 🔊 Suena el cambio de página persistente
		AudioManager.play_sfx_persistente(sonido_cambio_pagina)

	get_tree().change_scene_to_file(scene_path)
