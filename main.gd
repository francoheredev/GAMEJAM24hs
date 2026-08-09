extends Node2D
## Script del nodo raíz de main.tscn. Solo arranca la partida.
## Cuando exista el menú principal, esto se va.

func _ready() -> void:
	GameManager.start_game()
