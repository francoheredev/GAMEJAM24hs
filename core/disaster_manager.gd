class_name DisasterManager
extends Node
## Elige qué objeto del escenario sufre un desastre y cuándo.

## Nodo que contiene los objetos con desastre.
@export var disasters_container: Node2D

## Segundos entre desastres al empezar la partida.
@export var start_interval: float = 6.0
## Segundos entre desastres al máximo de dificultad.
@export var min_interval: float = 2.5
## Cuántos segundos tarda en llegar al máximo de dificultad.
@export var ramp_duration: float = 90.0
## Desastres simultáneos permitidos al empezar.
@export var start_max_concurrent: int = 1
## Desastres simultáneos permitidos al máximo de dificultad.
@export var max_concurrent_cap: int = 3

var _disasters: Array[Disaster] = []
var _elapsed: float = 0.0
var _spawn_timer: float = 0.0


func _ready() -> void:
	if disasters_container == null:
		push_error("[DisasterManager] Falta asignar disasters_container.")
		return

	for child in disasters_container.get_children():
		if child is Disaster:
			_disasters.append(child)

	print("[DisasterManager] Desastres en escena: ", _disasters.size())
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_over.connect(_on_game_over)


## Activa un objeto disponible al azar.
func trigger_disaster() -> Disaster:
	if not GameManager.is_playing():
		return null

	var candidates: Array[Disaster] = []
	for disaster in _disasters:
		if disaster.can_activate():
			candidates.append(disaster)

	if candidates.is_empty():
		print("[DisasterManager] No hay objetos disponibles.")
		return null

	var chosen: Disaster = candidates.pick_random()
	chosen.activate()
	EventBus.disaster_spawned.emit(chosen)
	return chosen


func get_active_disasters() -> Array[Disaster]:
	var active: Array[Disaster] = []
	for disaster in _disasters:
		if disaster.is_active:
			active.append(disaster)
	return active


## Resuelve el desastre más cerca de fallar.
func resolve_oldest_disaster() -> void:
	var active := get_active_disasters()
	if active.is_empty():
		print("[DisasterManager] No hay desastres activos.")
		return

	var oldest: Disaster = active[0]
	for disaster in active:
		if disaster.get_progress() > oldest.get_progress():
			oldest = disaster

	oldest.resolve()


## Devuelve todos los objetos a su estado inicial.
func reset_all() -> void:
	for disaster in _disasters:
		disaster.reset()
	print("[DisasterManager] Objetos reiniciados.")


## Congela los desastres en curso sin resolverlos.
func freeze_all() -> void:
	var frozen := 0
	for disaster in get_active_disasters():
		disaster.set_process(false)
		frozen += 1
	print("[DisasterManager] Desastres congelados: ", frozen)


func _on_game_started() -> void:
	for disaster in _disasters:
		disaster.set_process(true)
	reset_all()
	_elapsed = 0.0
	_spawn_timer = get_current_interval()


func _on_game_over(_score: int) -> void:
	freeze_all()


func _process(delta: float) -> void:
	if not GameManager.is_playing():
		return

	_elapsed += delta
	_spawn_timer -= delta

	if _spawn_timer <= 0.0:
		_spawn_timer = get_current_interval()
		if get_active_disasters().size() < get_current_max_concurrent():
			trigger_disaster()


## 0.0 al empezar, 1.0 cuando la dificultad llegó al techo.
func get_difficulty() -> float:
	if ramp_duration <= 0.0:
		return 1.0
	return clampf(_elapsed / ramp_duration, 0.0, 1.0)


func get_current_interval() -> float:
	return lerpf(start_interval, min_interval, get_difficulty())


func get_current_max_concurrent() -> int:
	return int(round(lerpf(start_max_concurrent, max_concurrent_cap, get_difficulty())))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_spawn_disaster"):
		trigger_disaster()
	elif event.is_action_pressed("debug_resolve_disaster"):
		resolve_oldest_disaster()
	elif event.is_action_pressed("debug_reset"):
		GameManager.start_game()
