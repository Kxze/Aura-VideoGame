extends Button

func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("pressed", Callable(self, "_on_button_pressed"))

# Hover → más brillante
func _on_mouse_entered():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(2, 2, 1.5) # Brilla con glow
	add_theme_stylebox_override("hover", style)

# Normal → blanco base
func _on_mouse_exited():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1) # Normal
	add_theme_stylebox_override("normal", style)

# Click → aún más intenso
func _on_button_pressed():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(3, 3, 2) # Glow más fuerte
	add_theme_stylebox_override("pressed", style)
