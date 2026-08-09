extends Node2D
## Cursor custom. Sigue al mouse y cambia según lo que haya debajo.
## Lee Clickable.hovered, no necesita conectarse a nada.

## Escala del cursor cuando hay algo interactuable debajo.
@export var hover_scale: float = 1.4
## Qué tan rápido reacciona al cambio.
@export var scale_speed: float = 12.0

@onready var _sprite: Node2D = $Sprite
@onready var _hold_ring: TextureProgressBar = $HoldRing


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	top_level = true


func _process(delta: float) -> void:
	global_position = get_global_mouse_position()

	var target: Clickable = Clickable.hovered
	var target_scale := hover_scale if target != null else 1.0
	_sprite.scale = _sprite.scale.lerp(Vector2.ONE * target_scale, delta * scale_speed)

	var progress: float = target.get_hold_progress() if target != null else 0.0
	_hold_ring.visible = progress > 0.0
	_hold_ring.value = progress * 100.0
