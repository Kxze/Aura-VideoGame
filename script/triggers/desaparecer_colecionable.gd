extends Area3D

@onready var casco: Node3D = $"../CascoMesh"  # 👈 ajusta el nombre real
@onready var particle: GPUParticles3D = $"../GPUParticles3D"  # 👈 ajusta si es necesario
@onready var sonido_casco = preload("res://sonidos/desbloqueaColeccionable.wav")
@onready var dialogo_aura = preload("res://dialogos/aura/Aura2-RV.wav")
@onready var notificacion_scene = preload("res://scenes/notificacionColeccionable.tscn")

func _ready() -> void:
	print("🧠 Estado inicial del casco:", AudioManager.casco_obtenido)
	if AudioManager.casco_obtenido:
		_deshabilitar_area()

func _on_body_entered(body: Node3D) -> void:
	print("👣 body_entered:", body.name)
	if body.name != "Player":
		return
	if AudioManager.casco_obtenido:
		return

	# 🪖 Oculta el casco y partículas
	casco.visible = false
	particle.emitting = false
	AudioManager.casco_obtenido = true

	# 🔊 Sonidos
	var am = get_node_or_null("/root/AudioManager")
	if am:
		if am.has_method("play_sonidoCasco"):
			am.play_sonidoCasco(sonido_casco)
		if am.has_method("play_dialogo_aura"):
			am.play_dialogo_aura(dialogo_aura)
	else:
		push_warning("⚠️ AudioManager no encontrado o método faltante")

	_mostrar_notificacion()
	_deshabilitar_area()

func _mostrar_notificacion() -> void:
	var notif = notificacion_scene.instantiate()
	get_tree().root.add_child(notif)
	notif.visible = true

func _deshabilitar_area() -> void:
	casco.visible = false
	particle.emitting = false
	monitoring = false
	collision_layer = 0
	collision_mask = 0
