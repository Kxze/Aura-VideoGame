extends Node3D

@onready var musica_level1 = preload("res://musica/MelodiaPrincipal.mp3")
@onready var dialogo_alex1 = preload("res://dialogos/alex/Alex1-IA_PE.wav")

func _ready():
	# 🎵 Iniciar música del nivel
	if AudioManager.musica_player.stream != musica_level1:
		AudioManager.play_music(musica_level1, true)

	# 🕐 Espera un poco antes de reproducir el diálogo
	await get_tree().create_timer(1.5).timeout

	# 🎙️ Diálogo de Alex (solo una vez por sesión)
	if AudioManager.has_method("play_dialogo_alex"):
		if not AudioManager.alex_dialogos_sonados.has("alex1") or not AudioManager.alex_dialogos_sonados["alex1"]:
			AudioManager.play_dialogo_alex(dialogo_alex1, "alex1")
			print("🎧 Reproduciendo diálogo Alex1 por primera vez.")
		else:
			print("🔇 Diálogo Alex1 ya fue reproducido anteriormente, no se repite.")
