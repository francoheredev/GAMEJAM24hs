extends Node
## Bus central de señales. Nadie referencia nodos del otro: todo pasa por acá.
## Si agregás una señal, anotala en NOTAS.md y avisale al otro.
##
## IMPORTANTE: las señales van SIN tipo en los parámetros.
## Tipar "disaster: Disaster" crea una dependencia circular con disaster.gd
## y rompe la compilación de todos los autoloads.

# --- Desastres --- (el parámetro es siempre un Disaster)
signal disaster_spawned(disaster)
signal disaster_resolved(disaster)
signal disaster_failed(disaster)

# --- Sospecha ---
signal suspicion_changed(value: float)
signal streamer_turned_around()

# --- Flujo de juego ---
signal game_started()
signal game_over(score: int)

# --- Audio ---
signal play_sfx(sfx_name: String)
