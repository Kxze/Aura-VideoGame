extends PlayerState

var dash_time := 0.3
var dash_speed := 15.0
var timer := 0.0
var dash_dir := 1  # dirección fija del dash
var suspend_air_time := 0.5  # tiempo que se queda suspendido en el aire
var suspended := false

# Cooldown
var dash_cooldown := .5  # segundos
var can_dash := true  # indica si el jugador puede hacer dash

func enter(previous_state_path: String, data := {}):
	if not can_dash:
		emit_signal("finished", "Idle")
		return

	timer = 0.0
	player.animationPlayer.play("dash")
	can_dash = false

	dash_dir = player.last_facing

	# Activar Trail
	var trail_node = player.get_node("Trail") # ajusta la ruta si es diferente
	if trail_node:
		trail_node.start_trail()

	# Suspensión en el aire
	if not player.is_on_floor():
		suspended = true
		player.velocity.y = 0
		await get_tree().create_timer(suspend_air_time).timeout
		suspended = false

	reset_dash_cooldown()

func physics_update(delta: float):
	timer += delta

	# Velocidad horizontal fija
	player.velocity.x = dash_dir * dash_speed

	# Gravedad solo si no está suspendido
	if not suspended:
		player.velocity.y += player.GRAVITY

	player.move_and_slide()

	# Terminar dash
	if timer >= dash_time:
		emit_signal("finished", "Idle")


func exit():
	# Desactivar Trail
	var trail_node = player.get_node("Trail") # ajusta la ruta si es diferente
	if trail_node:
		trail_node.stop_trail()

# Función para resetear el dash
func reset_dash_cooldown():
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
