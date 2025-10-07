extends WorldEnvironment

var current_environment: Environment

func _ready():
	# Guarda su propio environment automáticamente
	current_environment = self.environment

func registrar_environment(env: Environment) -> void:
	current_environment = env

func set_brightness(value: float) -> void:
	if current_environment:
		current_environment.adjustment_enabled = true
		current_environment.adjustment_brightness = value
		print("☀️ Brillo global ajustado a:", value)
	else:
		push_warning("⚠️ No hay Environment registrado para ajustar el brillo.")
