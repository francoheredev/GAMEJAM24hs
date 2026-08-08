extends Disaster
## Desastre placeholder para probar el DisasterManager.
## Se borra cuando existan los desastres reales.

func _on_activate() -> void:
	modulate = Color.ORANGE_RED
	print("[DebugDisaster] activado en ", get_parent().name)

func _on_resolve() -> void:
	modulate = Color.LIME_GREEN
	print("[DebugDisaster] resuelto")
	queue_free()

func _on_fail() -> void:
	modulate = Color.DIM_GRAY
	print("[DebugDisaster] FALLÓ")
	queue_free()
