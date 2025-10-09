extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

func _ready():
	# Cargar y reproducir el video
	video.stream = preload("res://Videos/Cinemática-Final.ogv")
	video.play()

	# Conectar señal al terminar
	video.finished.connect(_on_video_finished)

	# Ajustar a pantalla completa
	_set_fullscreen_video()

	# Reajustar si cambia el tamaño de la ventana
	get_viewport().size_changed.connect(_set_fullscreen_video)


func _set_fullscreen_video():
	# Asegura que el VideoStreamPlayer cubra toda la pantalla (anclado a los bordes)
	video.anchor_left = 0.0
	video.anchor_top = 0.0
	video.anchor_right = 1.0
	video.anchor_bottom = 1.0
	video.offset_left = 0.0
	video.offset_top = 0.0
	video.offset_right = 0.0
	video.offset_bottom = 0.0


func _on_video_finished():
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")


func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
