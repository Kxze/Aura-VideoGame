extends Node

var brillo_actual: float = 1.0
var environments: Array[Environment] = []

func _ready():
	actualizar_todos_los_environments()

func set_brightness(value: float):
	brillo_actual = value
	actualizar_todos_los_environments()

func registrar_environment(env: Environment):
	if env and not environments.has(env):
		environments.append(env)
		env.adjustment_brightness = brillo_actual

func actualizar_todos_los_environments():
	for env in environments:
		if env:
			env.adjustment_brightness = brillo_actual
