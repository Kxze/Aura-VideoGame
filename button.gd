extends Button

func _ready():
	connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	# Cambia a la escena de nueva partida
		get_tree().change_scene_to_file("res://scenes/level_1.tscn")


	
