extends Control

func _ready():
	$Panel.mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel.connect("gui_input", Callable(self, "_on_panel_input"))

func _on_panel_input(event):
	if event is InputEventMouseButton and event.pressed:
		_cambiar_a_menu()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		_cambiar_a_menu()

func _cambiar_a_menu():
	print("Cambiando a menu_principal...")
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
