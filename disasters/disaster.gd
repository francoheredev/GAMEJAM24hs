class_name Disaster
extends Node2D
## Clase base de todos los desastres. Cada desastre concreto hereda de acá
## y sobrescribe SOLO los tres métodos _on_*. No toquen activate/resolve/fail.

signal resolved
signal failed

## Segundos que tiene el jugador para arreglarlo antes de que falle.
@export var time_limit: float = 12.0
## Cuánta sospecha suma si falla (0.0 a 1.0). Con 0.34, tres fallos = game over.
@export var suspicion_on_fail: float = 0.34
## Nombre legible, para debug y para el HUD.
@export var display_name: String = "Desastre"

var is_active: bool = false
var _time_left: float = 0.0


func activate() -> void:
	if is_active:
		return
	is_active = true
	_time_left = maxf(time_limit, 0.01)
	_on_activate()


func resolve() -> void:
	if not is_active:
		return
	is_active = false
	_on_resolve()
	resolved.emit()
	EventBus.disaster_resolved.emit(self)


func fail() -> void:
	if not is_active:
		return
	is_active = false
	_on_fail()
	failed.emit()
	EventBus.disaster_failed.emit(self)


## Devuelve 0.0 (recién empezó) a 1.0 (a punto de fallar). Útil para el HUD.
func get_progress() -> float:
	if time_limit <= 0.0:
		return 1.0
	return clampf(1.0 - (_time_left / time_limit), 0.0, 1.0)


func _process(delta: float) -> void:
	if not is_active:
		return
	_time_left -= delta
	if _time_left <= 0.0:
		fail()


# --- Sobrescribir en cada desastre concreto ---

## Arranca la animación, el sonido, lo que sea. El gato empieza a caminar.
func _on_activate() -> void:
	pass

## El jugador lo arregló. Animación de alivio, el gato baja del estante.
func _on_resolve() -> void:
	pass

## Se acabó el tiempo. El jarrón se rompe, el tostador explota.
func _on_fail() -> void:
	pass
