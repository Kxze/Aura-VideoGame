extends WorldEnvironment

func _ready():
	if Engine.has_singleton("GlobalBrightness"):
		GlobalBrightness.registrar_environment(self.environment)
	else:
		push_warning("⚠️ GlobalBrightness no está disponible como autoload.")
