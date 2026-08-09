extends Node
## Escena de pruebas para el sistema de interacción.
## Activa a mano los desastres puestos en la escena, porque acá
## no existe el DisasterManager que lo hace en main.tscn.

func _ready() -> void:
	for disaster in _find_disasters(self):
		disaster.activate()
		print("[Sandbox] Activado: ", disaster.name)


## Busca recursivamente todos los Disaster que cuelguen de la escena.
func _find_disasters(node: Node) -> Array[Disaster]:
	var found: Array[Disaster] = []
	for child in node.get_children():
		if child is Disaster:
			found.append(child)
		found.append_array(_find_disasters(child))
	return found


func _unhandled_input(event: InputEvent) -> void:
	## Reactiva todo con F4, para probar sin reiniciar la escena.
	if event.is_action_pressed("debug_reset"):
		for disaster in _find_disasters(self):
			disaster.activate()
		print("[Sandbox] Todo reactivado.")
