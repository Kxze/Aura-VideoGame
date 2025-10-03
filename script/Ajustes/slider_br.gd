extends HSlider

#para cambiar el brillo global del juego
func _on_value_changed(value: float) -> void:
	GlobalBrightnessWorldEnvironment.environment.adjustment_brightness = value
