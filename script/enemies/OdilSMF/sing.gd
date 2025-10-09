extends Odil_state
@onready var ray: RayCast3D = $"../../RayCast3D"
var isSing : bool = true
var projectile_ray = preload("res://scenes/triggers/ataque_julieta_particulas.tscn")
@onready var timer: Timer = $Timer
@onready var area_ray: Area3D = $"../../Area_ray"

func enter(previous_state_path : String, data := {}):
	odil.animation.play("Sing")
#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	
	ray.target_position = ray.to_local(odil.target.position)
	area_ray.global_transform = ray.global_transform
	if !isSing:
		return
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider.is_in_group("player"):
			shoot_ray()
#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	pass
#Esta funcion sobreescribe la funcion Input
func shoot_ray():
	var cast_point
	print("disparando")
	#var projectile_instance = projectile_ray.instantiate()
	cast_point = ray.to_local(ray.get_collision_point())
	
	isSing = false 
	timer.start()
	
	
	
func exit():
	pass


func _on_timer_timeout() -> void:
	isSing = true


func _on_area_ray_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		print("Dispare al jugador")
