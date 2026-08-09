extends Disaster


func _on_activate() -> void:
	$Visual.modulate = Color.RED


func _on_resolve() -> void:
	$Visual.modulate = Color.WHITE


func _on_fail() -> void:
	$Visual.modulate = Color.DARK_RED
