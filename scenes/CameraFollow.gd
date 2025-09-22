@tool
extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 15.0   # velocidad de seguimiento
@export var offset: Vector3 = Vector3(0, 5, -10)  # posición relativa al jugador
@export var smooth_factor: float = 0.2   # entre 0 y 1, menor = más suave


func _physics_process(delta: float) -> void:
	if not target:
		return

	var desired_position = target.global_transform.origin + offset
	# Suavizado tipo Papers Mario usando lerp de Vector3 en Godot 4
	global_transform.origin = global_transform.origin.lerp(desired_position, smooth_factor)
