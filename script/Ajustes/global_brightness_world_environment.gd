extends WorldEnvironment

func _ready():
	GlobalBrightness.registrar_environment($".".environment)
