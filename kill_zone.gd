extends Area3D

# Precargamos el sonido
@onready var pierde_punto_sound: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	# Crea el nodo de sonido y lo agrega a la escena (si no está ya)
	pierde_punto_sound.stream = preload("res://sonidos/pierdePunto.wav")
	add_child(pierde_punto_sound)
	pierde_punto_sound.autoplay = false
	pierde_punto_sound.volume_db = 0.0  # puedes ajustar volumen si es necesario


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		# 🔊 Reproduce el sonido de caída
		pierde_punto_sound.play()

		# Opcional: desactivar controles durante la transición
		body.controls_enabled = false

		# Transición de pantalla
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished

		# Detenemos el sonido al reaparecer
		if pierde_punto_sound.playing:
			pierde_punto_sound.stop()

		# Mover al jugador al spawnPoint
		if Player.spawnPoint:
			body.global_position = Player.spawnPoint.global_position
			body.velocity = Vector3.ZERO  # Resetear velocidad
			body.controls_enabled = true
			body.animationPlayer.play("Idle")
		else:
			get_tree().reload_current_scene()
