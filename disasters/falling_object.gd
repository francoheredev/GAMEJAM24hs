extends Disaster
## Objeto del escenario que se puede caer de su lugar.
## Usa un AnimatedSprite2D con tres animaciones: idle, alerta, caida.

## A partir de qué progreso pasa de idle a alerta.
@export var danger_threshold: float = 0.6
## Segundos de hold para resolverlo. En 0.0 se resuelve con un click.
@export var hold_duration: float = 0.0
## Texto que muestra el HUD al pasar el mouse.
@export var interaction_hint: String = "Acomodar"

@onready var _anim: AnimatedSprite2D = $Visual
@onready var _clickable: Clickable = get_node_or_null("Clickable")

var _in_danger: bool = false


func _ready() -> void:
	if _clickable != null:
		_clickable.hold_duration = hold_duration
		_clickable.hint = interaction_hint
		_clickable.clicked.connect(resolve)
		_clickable.hold_completed.connect(resolve)
	_set_dormant()


func _on_activate() -> void:
	_in_danger = false
	_set_clickable(true)
	_anim.play("idle")


func _on_resolve() -> void:
	_set_clickable(false)
	EventBus.play_sfx.emit("object_saved")
	_set_dormant()


func _on_fail() -> void:
	_set_clickable(false)
	EventBus.play_sfx.emit("object_break")
	_anim.play("caida")
	## Queda tirado en el piso hasta que reinicie la partida.


func _on_reset() -> void:
	_in_danger = false
	_set_dormant()


func _process(delta: float) -> void:
	super._process(delta)
	if not is_active or _in_danger:
		return

	if get_progress() >= danger_threshold:
		_in_danger = true
		_anim.play("alerta")


## Objeto quieto en su lugar: primer frame del idle, sin animar.
func _set_dormant() -> void:
	_set_clickable(false)
	_anim.animation = "idle"
	_anim.frame = 0
	_anim.pause()


func _set_clickable(value: bool) -> void:
	if _clickable != null:
		_clickable.enabled = value
