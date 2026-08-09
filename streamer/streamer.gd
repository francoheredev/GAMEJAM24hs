class_name Streamer
extends Node2D
## El streamer. Reacciona a la sospecha con amagues y se da vuelta al perder.

## A partir de qué nivel de sospecha empieza a amagar.
@export var nervous_threshold: float = 0.5
## Cada cuántos segundos amaga cuando está nervioso.
@export var glance_interval: float = 4.0

var _suspicion: float = 0.0
var _glance_timer: float = 0.0
var _is_turned: bool = false


func _ready() -> void:
	EventBus.suspicion_changed.connect(_on_suspicion_changed)
	EventBus.streamer_turned_around.connect(_on_turned_around)
	EventBus.game_started.connect(_on_game_started)


func _process(delta: float) -> void:
	if _is_turned or _suspicion < nervous_threshold:
		return

	_glance_timer -= delta
	if _glance_timer <= 0.0:
		_glance_timer = glance_interval
		_play_glance()


## Amague: hace el ademán de darse vuelta y se arrepiente.
func _play_glance() -> void:
	print("[Streamer] Amague.")
	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", 12.0, 0.25)
	tween.tween_interval(0.3)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.4)


func _on_turned_around() -> void:
	if _is_turned:
		return
	_is_turned = true
	print("[Streamer] Se dio vuelta. Fin del stream.")

	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", 180.0, 0.6)
	tween.parallel().tween_property(self, "modulate", Color.DARK_RED, 0.6)


func _on_game_started() -> void:
	_is_turned = false
	_suspicion = 0.0
	_glance_timer = glance_interval
	rotation_degrees = 0.0
	modulate = Color.WHITE


func _on_suspicion_changed(value: float) -> void:
	_suspicion = value
