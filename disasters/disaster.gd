class_name Disaster
extends Node2D

signal resolved
signal failed

@export var time_limit: float = 12.0
@export var suspicion_on_fail: float = 0.34
@export var display_name: String = "Desastre"

var is_active: bool = false
var _time_left: float = 0.0



func _ready() -> void:
	## Se conecta solo si hay un hijo llamado Clickable.
	## Los desastres sin interacción (debug) funcionan igual.
	var clickable := get_node_or_null("Clickable")
	if clickable == null:
		return

	clickable.clicked.connect(resolve)
	clickable.hold_completed.connect(resolve)

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
