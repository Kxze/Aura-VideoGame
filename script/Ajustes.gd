extends Popup

func _on_btn_home_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
