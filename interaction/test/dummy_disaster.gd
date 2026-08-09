extends Disaster


func _on_activate() -> void:
	$Visual.modulate = Color.RED


func _on_resolve() -> void:
	$Visual.modulate = Color.WHITE
	print("RESUELTO: ", name, " | frame ", Engine.get_process_frames())


func _on_fail() -> void:
	$Visual.modulate = Color.DARK_RED
