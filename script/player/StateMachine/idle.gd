extends PlayerState

# 🎵 Sonido de aterrizaje
@onready var land_sound = preload("res://sonidos/cae_salto.wav")

# --- Al entrar al estado ---
func enter(previous_state_path : String, data := {}):
	player.lumiere_area.visible = false
	player.animationPlayer.play("idle")
	player.invencible = false

	# 🔊 Si el jugador viene del estado InAir y fue un salto manual, reproducir sonido
	if previous_state_path.ends_with("InAir") and data.has("did_jump") and data["did_jump"]:
		AudioManager.play_and_get_duration(land_sound)

# --- Física del estado ---
func physics_update(delta: float):
	# Si deja de tocar el suelo, pasa a InAir
	if not player.is_on_floor():
		emit_signal("finished", "InAir")

	# Si presiona salto en el suelo
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		emit_signal("finished", "InAir", {"Jump" : true})
	if Input.is_action_just_pressed("Lumiere") and player.can_lumiere:
		emit_signal("finished","Lumiere")
	if player.health <= 0:
		emit_signal("finished","Dead")
	# Frenado suave horizontal
	player.velocity.x = lerpf(player.velocity.x, 0, 0.9)
	player.move_and_slide()
	player.global_position.z = 0

# --- Actualización por frame ---
func update(_delta: float):
	# Si hay movimiento horizontal, pasar a Walking
	if player.movInput.x != 0:
		emit_signal("finished", "Walking")
