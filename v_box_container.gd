extends VBoxContainer

func _ready():
	# Conectamos cada botón a su función
	$Button.connect("pressed", Callable(self, "_on_nueva_partida_pressed"))
	$Button2.connect("pressed", Callable(self, "_on_continuar_pressed"))
	$Button3.connect("pressed", Callable(self, "_on_coleccionista_pressed"))
	$Button4.connect("pressed", Callable(self, "_on_ajustes_pressed"))
	$Button5.connect("pressed", Callable(self, "_on_salir_pressed"))


func _on_nueva_partida_pressed():
	# Cambia a la escena de nueva partida
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func _on_continuar_pressed():
	# Aquí pondrás el sistema de carga de partida
	print("Continuar partida (cargar juego)")

func _on_coleccionista_pressed():
	# Aquí abre la escena de coleccionista
	print("Abrir coleccionista")

func _on_ajustes_pressed():
	# Aquí abre la escena de ajustes
	print("Abrir ajustes")

func _on_salir_pressed():
	# Cierra el juego
	get_tree().quit()
