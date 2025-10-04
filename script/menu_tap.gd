extends Control
@onready var musica_menu = preload("res://musica/MelodiaMenu.mp3")

func _ready():
	# Solo inicia si no hay música sonando
	if not AudioManager.musica_player.playing:
		AudioManager.play_music(musica_menu, true)


func _unhandled_input(event):
	# Si se presiona cualquier tecla
	if event is InputEventKey and event.pressed:
		_cambiar_a_menu()

	# Si se hace clic con el mouse
	if event is InputEventMouseButton and event.pressed:
		_cambiar_a_menu()

func _cambiar_a_menu():
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
