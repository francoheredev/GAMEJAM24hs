extends Disaster
## Desastre genérico: un objeto se está por caer de su lugar.
## Sirve para todos los desastres de tipo "algo se cae".
## Se configura por Inspector, no hace falta un script por objeto.

## A partir de qué progreso entra en "últimos segundos".
@export var danger_threshold: float = 0.6
## Cuánto se tambalea el objeto, en grados.
@export var wobble_degrees: float = 8.0
## Segundos de hold para resolverlo. En 0.0 se resuelve con un click.
@export var hold_duration: float = 0.0
## Texto que muestra el HUD al pasar el mouse.
@export var interaction_hint: String = "Acomodar"

var _in_danger: bool = false
var _wobble_tween: Tween


func _ready() -> void:
	var clickable := get_node_or_null("Clickable")
	if clickable == null:
		return

	clickable.hold_duration = hold_duration
	clickable.hint = interaction_hint
	clickable.clicked.connect(resolve)
	clickable.hold_completed.connect(resolve)

func _on_activate() -> void:
	_in_danger = false
	$Visual.modulate = Color.WHITE
	_start_wobble(wobble_degrees, 0.8)


func _on_resolve() -> void:
	_stop_wobble()
	EventBus.play_sfx.emit("object_saved")
	_finish(Color.LIME_GREEN)


func _on_fail() -> void:
	_stop_wobble()
	EventBus.play_sfx.emit("object_break")
	## Se cae y se rompe.
	var tween := create_tween()
	tween.tween_property($Visual, "position:y", $Visual.position.y + 80.0, 0.35)
	tween.parallel().tween_property($Visual, "rotation_degrees", 90.0, 0.35)
	tween.tween_callback(_finish.bind(Color.DIM_GRAY))


func _process(delta: float) -> void:
	super._process(delta)
	if not is_active or _in_danger:
		return

	if get_progress() >= danger_threshold:
		_in_danger = true
		## Últimos segundos: se tambalea más rápido y más fuerte.
		_start_wobble(wobble_degrees * 2.0, 0.25)


func _start_wobble(degrees: float, duration: float) -> void:
	_stop_wobble()
	_wobble_tween = create_tween().set_loops()
	_wobble_tween.tween_property($Visual, "rotation_degrees", degrees, duration)
	_wobble_tween.tween_property($Visual, "rotation_degrees", -degrees, duration)


func _stop_wobble() -> void:
	if _wobble_tween != null and _wobble_tween.is_valid():
		_wobble_tween.kill()
	$Visual.rotation_degrees = 0.0


func _finish(color: Color) -> void:
	$Visual.modulate = color
	var tween := create_tween()
	tween.tween_interval(0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
