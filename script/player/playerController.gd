class_name Player extends CharacterBody3D
#variables for access to the model
@onready var pivot: Sprite3D = $Sprite3D
@onready var animation_player = $Sprite3D/AuraModelo3D/AnimationPlayer
#variables properties for the movement of the player
@export var speed: float = 3
@export var gravity: float = -45
@export var jumpForce: float = 15 
@export var jump_Buffer_Time: float = .1  
@export var rotationSpeed: float = 5
#variables to improve the experience
var jump_Buffer :  bool = true
@onready var coyote_timer: Timer = $CoyoteTimer
var was_on_floor = is_on_floor()
var direction : Vector3
