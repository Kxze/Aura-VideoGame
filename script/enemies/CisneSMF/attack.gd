extends CisneState

@onready var ataque_sound = preload("res://sonidos/ataque.mp3")

func enter(previous_state_path: String, data := {}):
	# 🦢 Animación del ataque
	cisne.animationCisneNegro.play("Ataque")

	# 🔊 Reproducir sonido del ataque desde el AudioManager
	if AudioManager and AudioManager.has_method("play_ataque"):
		AudioManager.play_ataque(ataque_sound)
	else:
		print("⚠️ No se encontró AudioManager o método play_ataque().")

func physics_update(delta: float):
	pass

func update(_delta: float):
	pass

func handled_input(_event: InputEvent):
	pass

func exit():
	pass
