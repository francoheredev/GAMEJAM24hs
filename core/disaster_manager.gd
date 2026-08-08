class_name DisasterManager
extends Node
## Decide qué desastre aparece, cuándo y en qué slot.

## Nodo que contiene los Marker2D de posiciones.
@export var slots_container: Node2D
## Escenas de desastre que puede spawnear.
@export var disaster_scenes: Array[PackedScene] = []

var _slots: Array[Marker2D] = []


func _ready() -> void:
	if slots_container == null:
		push_error("[DisasterManager] Falta asignar slots_container.")
		return

	for child in slots_container.get_children():
		if child is Marker2D:
			_slots.append(child)

	print("[DisasterManager] Slots encontrados: ", _slots.size())


## Instancia un desastre al azar en un slot libre. Devuelve null si no hay lugar.
func spawn_disaster() -> Disaster:
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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_spawn_disaster"):
		spawn_disaster()
	elif event.is_action_pressed("debug_resolve_disaster"):
		resolve_oldest_disaster()
	elif event.is_action_pressed("debug_reset"):
		clear_all()
