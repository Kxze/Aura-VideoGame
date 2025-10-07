extends Node3D

@onready var dialogo_alex6 = preload("res://dialogos/alex/Alex6-IA_PE.wav")

func _ready() -> void:
	# ⏳ Espera un poco antes de iniciar el diálogo (para evitar solaparse con efectos de carga)
	await get_tree().create_timer(1.5).timeout

	# 🚫 Si ya se reprodujo antes, no repetir
	if AudioManager.alex6_sonado:
		print("🔇 Diálogo Alex6 ya reproducido anteriormente.")
		return

	# 🧠 Marca como reproducido
	AudioManager.alex6_sonado = true

	# 🎙️ Espera si hay otro diálogo activo antes de iniciar este
	if AudioManager.dialogo_en_progreso:
		print("🕓 Esperando a que termine el diálogo anterior antes de reproducir Alex6...")
		await AudioManager.esperar_dialogo_anterior()

	# 🎧 Reproduce el diálogo de Alex6
	if AudioManager.has_method("play_dialogo_alex"):
		AudioManager.play_dialogo_alex(dialogo_alex6)
		print("🎧 Diálogo Alex6 iniciado correctamente.")
	else:
		print("⚠️ No se encontró método play_dialogo_alex en AudioManager.")
