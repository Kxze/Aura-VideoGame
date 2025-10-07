extends CisneState

@onready var paso_sound = preload("res://sonidos/pasDeLumiere4.wav")

func enter(previous_state_path: String, data := {}):
	cisne.animationCisneBlanco.play("Caminar")

	# 🔊 Sonido de pasos del Cisne Blanco
	if AudioManager and AudioManager.has_method("play_paso_cisne"):
		AudioManager.play_paso_cisne(paso_sound)
	else:
		print("⚠️ No se encontró AudioManager o método play_paso_cisne().")
