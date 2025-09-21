extends MeshInstance3D
class_name CloneContainer

var lifetime:float
var remaining_time:float

func _ready() -> void:
	remaining_time * lifetime

func _process(delta: float) -> void:
	remaining_time -= delta
	set_instance_shader_parameter("opacity",clamp(remaining_time / lifetime, 0,1))
