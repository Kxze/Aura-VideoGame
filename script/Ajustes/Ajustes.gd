extends Popup

#para cerrar la ventana del pop up (aún no logro entender pq no sirve
func _on_btn_cerrar_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
