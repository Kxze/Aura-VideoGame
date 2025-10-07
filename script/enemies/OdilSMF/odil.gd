extends CharacterBody3D
class_name Odil

static var health = 3
@onready var animation: AnimationPlayer = $Odil/AnimationPlayer
static var isMoving: bool = true
static var isHurt: bool = false
func take_damage(amount: int):
	health -= amount
	print("Enemigo herido! HP:", health)
	if health <= 0:
		queue_free()
