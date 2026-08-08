extends Disaster
## Desastre de mentira para probar interacción sin depender de A.

func _on_activate() -> void:
	modulate = Color.RED

func _on_resolve() -> void:
	modulate = Color.GREEN

func _on_fail() -> void:
	modulate = Color.DIM_GRAY
