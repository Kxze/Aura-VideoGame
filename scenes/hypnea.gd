extends Control

func _unhandled_input(event):
	# Si se presiona cualquier tecla
	if event is InputEventKey and event.pressed:
		_cambiar_a_menu()

	# Si se hace clic con el mouse
	if event is InputEventMouseButton and event.pressed:
		_cambiar_a_menu()

func _cambiar_a_menu():
	get_tree().change_scene_to_file("res://scenes/menu_tap.tscn")
