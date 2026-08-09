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
	print("DISASTER LISTO: ", name)

	# Click normal
	$Clickable.clicked.connect(_on_clickable_clicked)

	# Hold completado
	$Clickable.hold_completed.connect(_on_clickable_hold_completed)

	activate()


func _on_clickable_clicked() -> void:
	print("SEÑAL CLICKED RECIBIDA POR DISASTER")
	print("is_active = ", is_active)

	resolve()


func _on_clickable_hold_completed() -> void:
	print("SEÑAL HOLD COMPLETED RECIBIDA POR DISASTER")
	print("is_active = ", is_active)

	resolve()


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
