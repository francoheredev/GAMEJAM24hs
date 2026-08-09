class_name DisasterManager
extends Node
## Decide qué desastre aparece, cuándo y en qué slot.

## Nodo que contiene los Marker2D de posiciones.
@export var slots_container: Node2D
## Escenas de desastre que puede spawnear.
@export var disaster_scenes: Array[PackedScene] = []
## Segundos entre spawns al empezar la partida.
@export var start_interval: float = 6.0
## Segundos entre spawns cuando la dificultad llegó al máximo.
@export var min_interval: float = 2.5
## Cuántos segundos de partida tarda en llegar al máximo de dificultad.
@export var ramp_duration: float = 90.0
## Desastres simultáneos permitidos al empezar.
@export var start_max_concurrent: int = 1
## Desastres simultáneos permitidos al máximo de dificultad.
@export var max_concurrent_cap: int = 3

var _slots: Array[Marker2D] = []
var _elapsed: float = 0.0
var _spawn_timer: float = 0.0

func _ready() -> void:
	if slots_container == null:
		push_error("[DisasterManager] Falta asignar slots_container.")
		return

	for child in slots_container.get_children():
		if child is Marker2D:
			_slots.append(child)

	print("[DisasterManager] Slots encontrados: ", _slots.size())
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_over.connect(_on_game_over)


## Instancia un desastre al azar en un slot libre. Devuelve null si no hay lugar.
func spawn_disaster() -> Disaster:
	if not GameManager.is_playing():
		return null

	if disaster_scenes.is_empty():
		push_warning("[DisasterManager] No hay escenas de desastre asignadas.")
		return null

	var slot := _get_free_slot()
	if slot == null:
		print("[DisasterManager] Todos los slots ocupados.")
		return null

	var scene: PackedScene = disaster_scenes.pick_random()
	var disaster: Disaster = scene.instantiate()

	slot.add_child(disaster)
	disaster.activate()
	EventBus.disaster_spawned.emit(disaster)

	return disaster


## Un slot está libre si no tiene hijos.
func _get_free_slot() -> Marker2D:
	var free_slots: Array[Marker2D] = []
	for slot in _slots:
		if slot.get_child_count() == 0:
			free_slots.append(slot)

	if free_slots.is_empty():
		return null
	return free_slots.pick_random()


## Devuelve todos los desastres activos en escena.
func get_active_disasters() -> Array[Disaster]:
	var active: Array[Disaster] = []
	for slot in _slots:
		for child in slot.get_children():
			if child is Disaster and child.is_active:
				active.append(child)
	return active


## Resuelve el desastre más viejo (el que está más cerca de fallar).
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


## Borra todos los desastres de la escena, sin emitir señales.
func clear_all() -> void:
	for slot in _slots:
		for child in slot.get_children():
			child.queue_free()
	print("[DisasterManager] Escena limpiada.")

func _on_game_started() -> void:
	clear_all()
	_elapsed = 0.0
	_spawn_timer = get_current_interval()

func _on_game_over(_score: int) -> void:
	freeze_all()


## Congela los desastres que quedaron en pantalla, sin borrarlos.
## Apagar _process detiene el timer interno de la clase base Disaster.
func freeze_all() -> void:
	var frozen := 0
	for disaster in get_active_disasters():
		disaster.set_process(false)
		frozen += 1
	print("[DisasterManager] Desastres congelados: ", frozen)

func _process(delta: float) -> void:
	if not GameManager.is_playing():
		return

	_elapsed += delta
	_spawn_timer -= delta

	if _spawn_timer <= 0.0:
		_spawn_timer = get_current_interval()
		if get_active_disasters().size() < get_current_max_concurrent():
			spawn_disaster()


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
		spawn_disaster()
	elif event.is_action_pressed("debug_resolve_disaster"):
		resolve_oldest_disaster()
	elif event.is_action_pressed("debug_reset"):
		GameManager.start_game()
