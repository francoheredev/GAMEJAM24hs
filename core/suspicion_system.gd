class_name SuspicionSystem
extends Node
## Mide cuánto sospecha el streamer. Sube cuando un desastre falla,
## baja sola con el tiempo. Al llegar a 1.0 el streamer se da vuelta.
## Con suspicion_on_fail = 0.34 en cada desastre, hacen falta 3 fallos.

## Cuánta sospecha se descuenta por segundo mientras no falla nada.
@export var decay_per_second: float = 0.03
## Cuánta sospecha se perdona al resolver un desastre a tiempo.
@export var relief_on_resolve: float = 0.05
## Cuánto suma F3, para debug.
@export var debug_increment: float = 0.2

var suspicion: float = 0.0
var is_running: bool = true


func _ready() -> void:
	EventBus.disaster_failed.connect(_on_disaster_failed)
	EventBus.disaster_resolved.connect(_on_disaster_resolved)
	EventBus.game_started.connect(reset)

func _process(delta: float) -> void:
	if not is_running or suspicion <= 0.0:
		return
	_set_suspicion(suspicion - decay_per_second * delta)


## Punto único de escritura: cualquier cambio pasa por acá.
func _set_suspicion(value: float) -> void:
	var new_value := clampf(value, 0.0, 1.0)
	if is_equal_approx(new_value, suspicion):
		return

	suspicion = new_value
	EventBus.suspicion_changed.emit(suspicion)

	if suspicion >= 1.0:
		_trigger_turn_around()


func _trigger_turn_around() -> void:
	if not is_running:
		return
	is_running = false
	print("[SuspicionSystem] El streamer se dio vuelta.")
	EventBus.streamer_turned_around.emit()


## Vuelve todo a cero. Lo va a llamar el GameManager al reiniciar.
func reset() -> void:
	is_running = true
	suspicion = 0.0
	EventBus.suspicion_changed.emit(suspicion)


func _on_disaster_failed(disaster) -> void:
	if not is_running:
		return
	var target := clampf(suspicion + disaster.suspicion_on_fail, 0.0, 1.0)
	print("[SuspicionSystem] Falló un desastre. Sospecha: %.2f" % target)
	_set_suspicion(target)

func _on_disaster_resolved(_disaster) -> void:
	if not is_running:
		return
	_set_suspicion(suspicion - relief_on_resolve)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_add_suspicion"):
		var target := clampf(suspicion + debug_increment, 0.0, 1.0)
		print("[SuspicionSystem] Debug. Sospecha: %.2f" % target)
		_set_suspicion(target)
