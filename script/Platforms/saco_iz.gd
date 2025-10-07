extends MeshInstance3D

var has_fallen : bool = false
var original_position : Vector3

@onready var collision_shape_3d: CollisionShape3D = $SacoColIz/CollisionShape3D
var damage: int = 1
@onready var Damage: Area3D = $SacoColIz/Damage


func _ready():
	original_position = global_position  # Guardamos la posición original

func _on_activar_plataforma_body_entered(body: Node3D) -> void:
	if body.name == "Player" and !has_fallen:
		has_fallen = true
		
		var opacity_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		var pos_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		# Caída y desvanecer
		opacity_tween.tween_property(self, "transparency", 1, 0.5)
		pos_tween.tween_property(self, "global_position", global_position + Vector3(0, -5, 0), 0.5)
		# Cuando termina, desactivar colisión y programar regeneración
		opacity_tween.finished.connect(Callable(self, "_disable_and_respawn"))

func _disable_and_respawn() -> void:
	collision_shape_3d.disabled = true
	await get_tree().create_timer(5.0).timeout  # Esperar 3 segundos
	_respawn_platform()
	

func _respawn_platform() -> void:
	# Restaurar posición, transparencia y colisión
	global_position = original_position
	transparency = 0
	collision_shape_3d.disabled = false
	
	
	
	# Pequeña animación de aparición
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "transparency", 0, 0.5)
	has_fallen = false

	
func Make_damage(body: Node3D):
	Odil.health -= damage
	Odil.isHurt = true
	print("Daño recibido. Salud actual:", Odil.health)

	if Odil.health <= 0:
		print("Odil muerea ")
		Odil.health = 3
	

func _on_damage_body_entered(body: Node3D) -> void:
	if body.name == "Odil":
		Make_damage(body)
