extends MeshInstance3D

var has_fallen: bool = false
var original_position: Vector3
var damage: int = 1

@onready var collision_shape_3d: CollisionShape3D = $SacoColIz/CollisionShape3D
@onready var Damage: Area3D = $SacoColIz/Damage
@onready var collision_area: CollisionShape3D = $SacoColIz/Damage/CollisionArea

func _ready():
	original_position = global_position

func _on_activar_plataforma_body_entered(body: Node3D) -> void:
	if body.name == "Player" and !has_fallen:
		has_fallen = true

		var opacity_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		var pos_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)

		opacity_tween.tween_property(self, "transparency", 1, 0.5)
		pos_tween.tween_property(self, "global_position", global_position + Vector3(0, -5, 0), 0.5)

		opacity_tween.finished.connect(Callable(self, "_disable_and_respawn"))

func _disable_and_respawn() -> void:
	collision_shape_3d.disabled = true
	collision_area.disabled = true  # 🚫 Desactivar detección del área de daño
	await get_tree().create_timer(5.0).timeout
	_respawn_platform()

func _respawn_platform() -> void:
	global_position = original_position
	transparency = 0
	collision_shape_3d.disabled = false
	collision_area.disabled = false  # ✅ Volver a activar el área de daño

	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "transparency", 0, 0.5)
	has_fallen = false

func Make_damage(body: Node3D):
	if !Odil.isInvulnerable:
		Odil.health -= damage
		Odil.isHurt = true
		Odil.isMoving = false
		print("Daño recibido. Salud actual:", Odil.health)

	if Odil.health <= 0:
		print("Odil muere")
		Odil.health = 3
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file("res://scenes/cinematica_final.tscn")

func _on_damage_body_entered(body: Node3D) -> void:
	if body.name == "Odil" and !collision_area.disabled:
		Make_damage(body)
