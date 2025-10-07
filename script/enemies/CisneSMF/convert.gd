extends CisneState

@onready var paso_sound = preload("res://sonidos/pasDeLumiere4.wav")

var is_walking_sound_played := false

func enter(previous_state_path: String, data := {}):
	# 🧠 Marca globalmente que ya está convertido
	AudioManager.cisne_convertido = true
	print("🌙 El Cisne se ha convertido definitivamente en Cisne Blanco.")

	# 🎬 Inicia animación
	cisne.animationCisneBlanco.play("Caminar")

	# 🔊 Sonido de paso solo si aún no fue reproducido
	if not is_walking_sound_played and AudioManager and AudioManager.has_method("play_paso_cisne"):
		AudioManager.play_paso_cisne(paso_sound)
		is_walking_sound_played = true
	else:
		print("⚠️ No se encontró AudioManager o método play_paso_cisne().")
