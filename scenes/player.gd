class_name Player
extends CharacterBody3D

@export var speed := 4
@export var jump := 20
@export var GRAVITY := -1.3

var movInput: Vector2 = Vector2.ZERO
var last_facing := 1  # 1 = derecha, -1 = izquierda

@onready var aura: Node3D = $Aura/AuraModelo3D
@onready var animationPlayer = $Aura/AuraModelo3D/AnimationPlayer

func _input(event: InputEvent) -> void:
	movInput.x = Input.get_axis("ui_left","ui_right")

func _process(delta: float) -> void:
	$Label3D.text = $StateMachine.state.name
