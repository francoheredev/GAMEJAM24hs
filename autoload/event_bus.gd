extends Node
## Bus central de señales. Nadie referencia nodos del otro: todo pasa por acá.
## Si agregás una señal, anotala en NOTAS.md y avisale al otro.

# --- Desastres ---
## Emitida por DisasterManager cuando aparece un desastre nuevo. (A emite, B escucha)
signal disaster_spawned(disaster: Disaster)
## Emitida por el propio Disaster cuando el jugador lo arregló a tiempo.
signal disaster_resolved(disaster: Disaster)
## Emitida por el propio Disaster cuando se acabó el tiempo.
signal disaster_failed(disaster: Disaster)

# --- Sospecha ---
## value va de 0.0 (tranquilo) a 1.0 (se da vuelta). (A emite, B escucha para el HUD)
signal suspicion_changed(value: float)
## El streamer se dio vuelta: fin de la partida.
signal streamer_turned_around()

# --- Flujo de juego ---
signal game_started()
signal game_over(score: int)

# --- Audio ---
## Cualquiera puede pedir un sonido sin saber dónde está el AudioManager.
signal play_sfx(sfx_name: String)
