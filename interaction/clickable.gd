class_name Clickable
extends Area2D
## Zona interactuable. Poné una de estas como hija de cualquier cosa
## que el jugador tenga que clickear. Necesita un CollisionShape2D adentro.

## Emitida en un click simple.
signal clicked
## Emitida cuando el jugador mantuvo apretado hold_duration segundos completos.
signal hold_completed
## Emitida si soltó antes de tiempo.
signal hold_cancelled

## Si es 0.0, alcanza un click. Si es mayor, hay que mantener apretado.
@export var hold_duration: float = 0.0
## Texto que muestra el HUD al pasar el mouse por encima. Ej: "Agarrar el jarrón"
@export var hint: String = ""
## Si está en false, ignora los clicks (desastre ya resuelto, etc).
@export var enabled: bool = true

# La implementación la escribe B en Fase 1.
# Por ahora esto es solo el contrato: A ya puede armar sus escenas
# de desastre poniendo Clickables y conectando las señales.
