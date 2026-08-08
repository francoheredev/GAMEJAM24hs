extends Node
## Reproduce SFX y música escuchando EventBus.play_sfx. Dueño: A.

func _ready() -> void:
	EventBus.play_sfx.connect(_on_play_sfx)

func _on_play_sfx(sfx_name: String) -> void:
	# TODO (A): reproducir el sonido correspondiente
	print("[AudioManager] SFX pedido: ", sfx_name)
