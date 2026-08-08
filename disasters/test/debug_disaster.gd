extends Disaster
## Desastre placeholder para probar el DisasterManager.
## Se borra cuando existan los desastres reales.

func _on_activate() -> void:
	modulate = Color.ORANGE_RED
	print("[DebugDisaster] activado en ", get_parent().name)

func _on_resolve() -> void:
	modulate = Color.LIME_GREEN
	print("[DebugDisaster] resuelto")
	_fade_out()

func _on_fail() -> void:
	modulate = Color.DIM_GRAY
	print("[DebugDisaster] FALLÓ")
	_fade_out()


## Espera para que se vea el color, se desvanece y recién ahí se libera.
## En los desastres reales, acá va la animación de cierre.
func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_interval(0.4)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
