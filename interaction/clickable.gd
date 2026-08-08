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

## Texto que muestra el HUD al pasar el mouse por encima.
@export var hint: String = "Resolver desastre"

## Si está en false, ignora los clicks.
@export var enabled: bool = true


func _ready() -> void:
	input_pickable = true


func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("EVENTO RECIBIDO")

		if InputMap.event_is_action(event, "interact"):
			print("CLICK DETECTADO")
			clicked.emit()
