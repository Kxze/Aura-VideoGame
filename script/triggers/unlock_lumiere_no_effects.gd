extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		# Activar habilidad
		body.can_lumiere = true
		
		# Buscar el nodo Lamp (BoneAttachment)
		var lamp_attachment = body.find_node("lamp", true, false)
		if lamp_attachment:
			# Buscar el modelo dentro del BoneAttachment
			var lamp_model = lamp_attachment.find_node("Lamp_model", true, false)
			if lamp_model:
				lamp_model.visible = true
