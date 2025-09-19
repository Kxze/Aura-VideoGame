class_name Player extends CharacterBody3D
@export var speed := 4
@export var jump := 15
var movInput : Vector2 = Vector2.ZERO
@export var GRAVITY := -14


@onready var aura: Node3D = $Aura/AuraModelo3D

@onready var animationPlayer = $Aura/AuraModelo3D/AnimationPlayer
func _input(event: InputEvent) -> void:
	movInput.x = Input.get_axis("ui_left","ui_right")
	print(movInput)
func _process(delta: float) -> void:
	$Label3D.text = $StateMachine.state.name
