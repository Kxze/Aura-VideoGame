extends GridContainer

# Teclas por defecto
#var default_bindings := {
#	"saltar": KEY_SPACE,
#	"izquierda": KEY_A,
#	"derecha": KEY_D,
#	"dash": KEY_E,
#	"correr": KEY_SHIFT
#}

# Acción que se está reconfigurando
#var waiting_for_key: String = ""

# Referencias directas a los botones
#@onready var btn_salto: Button = $BtnSalto
#@onready var btn_izq: Button = $BtnIzq
#@onready var btn_drch: Button = $BtnDrch
#@onready var btn_dash: Button = $BtnDash
#@onready var btn_run: Button = $BtnRun
#@onready var reestablecer: Button = $"../Reestablecer"

#func _ready():
	#btn_salto.pressed.connect(_on_button_pressed.bind("saltar"))
	#btn_izq.pressed.connect(_on_button_pressed.bind("izquierda"))
	#btn_drch.pressed.connect(_on_button_pressed.bind("derecha"))
	#btn_dash.pressed.connect(_on_button_pressed.bind("dash"))
	#btn_run.pressed.connect(_on_button_pressed.bind("correr"))
	#reestablecer.pressed.connect(_on_reset_pressed)

	#_update_button_labels()

#func _on_button_pressed(action_name: String):
	#waiting_for_key = action_name
	#reestablecer.text = "Presiona una tecla..."  # Feedback temporal

#func _input(event):
	#if waiting_for_key != "" and event is InputEventKey and event.pressed and not event.echo:
		#var new_key = event.keycode
		
		# No permitir ESC
		#if new_key == KEY_ESCAPE:
			#waiting_for_key = ""
			#reestablecer.text = "Reestablecer"
			#return
		
		# Quitar cualquier binding previo de esa tecla
		#for action in default_bindings.keys():
			#for ev in InputMap.action_get_events(action):
				#if ev is InputEventKey and ev.keycode == new_key:
					#InputMap.action_erase_event(action, ev)
		
		# Asignar nueva tecla
		#InputMap.action_erase_events(waiting_for_key)
		#var new_event := InputEventKey.new()
		#new_event.keycode = new_key
		#InputMap.action_add_event(waiting_for_key, new_event)
		
		#waiting_for_key = ""
		#reestablecer.text = "Reestablecer"
		#_update_button_labels()

#func _update_button_labels():
	#var events = InputMap.action_get_events("saltar")
	#btn_salto.text = OS.get_keycode_string(events[0].keycode) if events.size() > 0 else "Sin tecla"

	#events = InputMap.action_get_events("izquierda")
	#btn_izq.text = OS.get_keycode_string(events[0].keycode) if events.size() > 0 else "Sin tecla"

	#events = InputMap.action_get_events("derecha")
	#btn_drch.text = OS.get_keycode_string(events[0].keycode) if events.size() > 0 else "Sin tecla"

	#events = InputMap.action_get_events("dash")
	#btn_dash.text = OS.get_keycode_string(events[0].keycode) if events.size() > 0 else "Sin tecla"

	#events = InputMap.action_get_events("correr")
	#btn_run.text = OS.get_keycode_string(events[0].keycode) if events.size() > 0 else "Sin tecla"

#func _on_reset_pressed():
	#for action in default_bindings.keys():
		#InputMap.action_erase_events(action)
		#var ev = InputEventKey.new()
		#ev.keycode = default_bindings[action]
		#InputMap.action_add_event(action, ev)
	#_update_button_labels()
