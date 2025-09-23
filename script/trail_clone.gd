extends Node3D

@export var source_mesh: MeshInstance3D
@export var copy_interval: float = 0.1
@export var max_copies: int = 5
@export var source_material: ShaderMaterial

var copies_queue: Array = []
var active := false
var timer: Timer

func _ready() -> void:
	if not source_mesh:
		push_warning("No existe recurso 3D")
		return

	# Crear y configurar el Timer
	timer = Timer.new()
	timer.wait_time = copy_interval
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if active:
		copy_mesh()

func copy_mesh() -> void:
	if not source_mesh:
		return

	var pckdscene: PackedScene = load("res://scenes/aura_clone.tscn")
	var cloned_mesh: CloneContainer = pckdscene.instantiate()

	# Clonar la malla actual
	
	cloned_mesh.mesh = source_mesh.bake_mesh_from_current_skeleton_pose()
	cloned_mesh.global_transform = source_mesh.global_transform
	cloned_mesh.material_override = source_material
	add_child(cloned_mesh)
	copies_queue.append(cloned_mesh)

	# Limitar cantidad de clones
	if copies_queue.size() > max_copies:
		var oldest_copy = copies_queue.pop_front()
		oldest_copy.queue_free()

# Funciones públicas para controlar el trail
func start_trail():
	active = true

func stop_trail():
	active = false
