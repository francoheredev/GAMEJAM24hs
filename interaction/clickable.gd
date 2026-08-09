
class_name Clickable
extends Area2D

## Zona interactuable.
## Necesita un CollisionShape2D adentro.

## Emitida cuando se hace un click simple.
signal clicked

## Emitida cuando el jugador mantiene apretado
## durante hold_duration segundos completos.
signal hold_completed

## Emitida si el jugador suelta antes de completar el hold.
signal hold_cancelled

## Si es 0.0, se resuelve con un click.
## Si es mayor a 0.0, hay que mantener apretado.
@export var hold_duration: float = 0.0

## Texto que muestra el HUD al pasar el mouse por encima.
@export var hint: String = "Resolver desastre"

## Si está en false, ignora la interacción.
@export var enabled: bool = true

var is_holding: bool = false
var hold_timer: float = 0.0


func _ready() -> void:
	input_pickable = true


func _process(delta: float) -> void:
	if not is_holding:
		return

	hold_timer += delta

	if hold_timer >= hold_duration:
		is_holding = false
		hold_timer = 0.0

		print("HOLD COMPLETADO")
		hold_completed.emit()


func _input_event(_viewport, event, _shape_idx) -> void:
	if not enabled:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if InputMap.event_is_action(event, "interact"):

				# ─────────────────────────
				# BOTÓN PRESIONADO
				# ─────────────────────────
				if event.pressed:

					print("INTERACT PRESIONADO")

					# CLICK NORMAL
					if hold_duration <= 0.0:
						print("CLICK DETECTADO")
						clicked.emit()

					# HOLD
					else:
						is_holding = true
						hold_timer = 0.0
						print("HOLD INICIADO")


				# ─────────────────────────
				# BOTÓN SOLTADO
				# ─────────────────────────
				else:

					if is_holding:
						is_holding = false
						hold_timer = 0.0

						print("HOLD CANCELADO")
						hold_cancelled.emit()
