class_name Disaster
extends Node2D
## Objeto del escenario que puede sufrir un desastre.
## Vive permanentemente en main.tscn, no se instancia ni se libera.

signal resolved
signal failed

@export var time_limit: float = 12.0
@export var suspicion_on_fail: float = 0.34
@export var display_name: String = "Desastre"

var is_active: bool = false
## Si ya se rompió, no se puede volver a activar en esta partida.
var is_broken: bool = false

var _time_left: float = 0.0


## Puede activarse si no está corriendo ni roto.
func can_activate() -> bool:
	return not is_active and not is_broken


func activate() -> void:
	if not can_activate():
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
	is_broken = true
	_on_fail()
	failed.emit()
	EventBus.disaster_failed.emit(self)


## Vuelve al estado inicial. Lo llama el DisasterManager al empezar partida.
func reset() -> void:
	is_active = false
	is_broken = false
	_time_left = 0.0
	_on_reset()


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

func _on_activate() -> void:
	pass

func _on_resolve() -> void:
	pass

func _on_fail() -> void:
	pass

func _on_reset() -> void:
	pass
