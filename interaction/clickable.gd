class_name Clickable
extends Area2D
## Zona interactuable. Va como hija de cualquier cosa clickeable.
## Necesita un CollisionShape2D adentro.

## Emitida en un click simple.
signal clicked
## Emitida cuando se mantuvo apretado hold_duration segundos completos.
signal hold_completed
## Emitida si se soltó antes de tiempo o el mouse salió del área.
signal hold_cancelled
## Emitidas al entrar y salir con el mouse. Las usa el cursor y el HUD.
signal hover_entered
signal hover_exited

## Si es 0.0, se resuelve con un click. Si es mayor, hay que mantener apretado.
@export var hold_duration: float = 0.0
## Texto que muestra el HUD al pasar el mouse por encima.
@export var hint: String = "Resolver desastre"
## Si está en false, ignora la interacción.
@export var enabled: bool = true

## El Clickable que el mouse está tocando ahora, o null.
## Lo leen el Cursor y el HUD sin tener que buscar nodos.
static var hovered: Clickable = null

var is_holding: bool = false
var hold_timer: float = 0.0


func _ready() -> void:
	input_pickable = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


## 0.0 a 1.0. Lo usa el cursor para dibujar el anillo de progreso.
func get_hold_progress() -> float:
	if not is_holding or hold_duration <= 0.0:
		return 0.0
	return clampf(hold_timer / hold_duration, 0.0, 1.0)


func _process(delta: float) -> void:
	if not is_holding:
		return

	hold_timer += delta
	if hold_timer >= hold_duration:
		_stop_hold()
		hold_completed.emit()
		EventBus.play_sfx.emit("click")


func _unhandled_input(event: InputEvent) -> void:
	if not enabled or hovered != self:
		return

	if event.is_action_pressed("interact"):
		if hold_duration <= 0.0:
			clicked.emit()
			EventBus.play_sfx.emit("click")
		else:
			is_holding = true
			hold_timer = 0.0
		get_viewport().set_input_as_handled()

	elif event.is_action_released("interact"):
		_cancel_hold()


func _on_mouse_entered() -> void:
	if not enabled:
		return
	hovered = self
	hover_entered.emit()


func _on_mouse_exited() -> void:
	if hovered == self:
		hovered = null
	_cancel_hold()
	hover_exited.emit()


func _cancel_hold() -> void:
	if not is_holding:
		return
	_stop_hold()
	hold_cancelled.emit()


func _stop_hold() -> void:
	is_holding = false
	hold_timer = 0.0
