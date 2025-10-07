extends Node3D

@onready var dialogo_alex4 = preload("res://dialogos/alex/Alex4-IA_PE.wav")

func _ready() -> void:
	# ⏳ Espera breve antes de reproducir el diálogo (para no solaparlo con transiciones)
	await get_tree().create_timer(1.5).timeout

	# 🎙️ Reproduce el diálogo Alex4 (solo si no se ha escuchado antes)
	_reproducir_dialogo_alex4()


func _reproducir_dialogo_alex4() -> void:
	# 🚫 No repetir si ya fue reproducido
	if AudioManager.alex4_sonado:
		print("🔇 Diálogo Alex4 ya reproducido anteriormente.")
		return

	AudioManager.alex4_sonado = true  # ✅ Marcar reproducido

	# 🕓 Esperar si otro diálogo sigue activo
	if AudioManager.dialogo_en_progreso:
		print("🕓 Esperando a que termine el diálogo anterior antes de reproducir Alex4...")
		await AudioManager.esperar_dialogo_anterior()

	# 🎧 Reproducir el diálogo de Alex4
	if AudioManager.has_method("play_dialogo_alex"):
		AudioManager.play_dialogo_alex(dialogo_alex4)
		print("🎧 Diálogo Alex4 iniciado correctamente.")
	else:
		print("⚠️ No se encontró el método play_dialogo_alex en AudioManager.")
