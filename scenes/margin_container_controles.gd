extends MarginContainer

#para el cambio de entre ajustes y controles
@onready var btn_controles: Button = $"../MarginContainerAjustes/GridContainerAjustes/BtnControles"
@onready var margin_container_ajustes: MarginContainer = $"../MarginContainerAjustes"
@onready var margin_container_controles: MarginContainer = $"."

func _ready() -> void:	
	btn_controles.pressed.connect(_on_btn_controles_pressed)
	margin_container_controles.visible = false #MarginContainerControles oculto al iniciar

func _on_btn_controles_pressed() -> void:
	margin_container_ajustes.visible = false   #Oculta el MarginContainerAjustes
	margin_container_controles.visible = true  # Muestra el MarginContainerControles

func _on_reestablecer_pressed() -> void:
	margin_container_controles.visible = false
	margin_container_ajustes.visible = true
