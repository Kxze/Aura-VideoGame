extends Node3D

@onready var musica_level2 = preload("res://musica/MelodiaPrincipal.mp3")
@onready var dialogo_alex2 = preload("res://dialogos/alex/Alex2-IA_PE.wav")

func _ready() -> void:
	# 🎵 Música del nivel (solo cambia si no está ya sonando)
	if AudioManager.musica_player.stream != musica_level2:
		AudioManager.play_music(musica_level2, true)

	# 🕓 Esperar un poco tras cargar la escena
	await get_tree().create_timer(2.0).timeout

	# 🚫 Si el diálogo de Alex2 ya sonó, no repetir
	if AudioManager.alex2_sonado:
		print("🔇 Diálogo Alex2 ya reproducido en esta sesión.")
		return

	# 🎙️ Espera a que termine cualquier diálogo anterior (por ejemplo Alex1)
	if AudioManager.dialogo_en_progreso:
		print("🕓 Esperando a que termine el diálogo anterior (Alex1)...")
		await AudioManager.esperar_dialogo_anterior()

	# 🔊 Reproducir el diálogo de Alex2 una sola vez
	if AudioManager.has_method("play_dialogo_alex"):
		AudioManager.play_dialogo_alex(dialogo_alex2)
		AudioManager.alex2_sonado = true
		print("🎧 Reproduciendo diálogo de Alex2.")
