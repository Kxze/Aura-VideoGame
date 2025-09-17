extends Camera3D

@export var target: Node3D
@export var followSpeed: float = 4

@onready var offset = self.global_transform.origin

func _physics_process(delta: float) -> void:
	self.position = self.position.lerp(
		target.global_transform.origin + offset, delta * followSpeed
	)
