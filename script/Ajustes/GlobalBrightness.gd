extends Node

var environment_ref: Environment = null

func registrar_environment(env: Environment) -> void:
	environment_ref = env

func set_brightness(value: float) -> void:
	if environment_ref:
		environment_ref.adjustment_brightness = value
