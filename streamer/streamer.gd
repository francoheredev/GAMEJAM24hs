class_name Streamer
extends Node2D
## El streamer. Alterna entre varios idle, amaga cuando sube la sospecha
## y se da vuelta al perder.

## Nombres de las animaciones idle entre las que alterna.
@export var idle_animations: Array[String] = ["idle_1", "idle_2", "idle_3"]
## Cada cuántos segundos cambia de idle.
@export var idle_change_interval: float = 6.0
## A partir de qué sospecha empieza a amagar.
@export var nervous_threshold: float = 0.5
## Cada cuántos segundos amaga cuando está nervioso.
@export var glance_interval: float = 5.0

@onready var _anim: AnimatedSprite2D = $Visual

var _suspicion: float = 0.0
var _idle_timer: float = 0.0
var _glance_timer: float = 0.0
var _is_busy: bool = false
var _is_turned: bool = false


func _ready() -> void:
	EventBus.suspicion_changed.connect(_on_suspicion_changed)
	EventBus.streamer_turned_around.connect(_on_turned_around)
	EventBus.game_started.connect(_on_game_started)
	_play_random_idle()


func _process(delta: float) -> void:
	if _is_turned or _is_busy:
		return

	## Cambio de idle para que no se vea repetitivo.
	_idle_timer -= delta
	if _idle_timer <= 0.0:
		_idle_timer = idle_change_interval
		_play_random_idle()

	## Amague solo cuando la sospecha está alta.
	if _suspicion < nervous_threshold:
		return

	_glance_timer -= delta
	if _glance_timer <= 0.0:
		_glance_timer = glance_interval
		_play_glance()


## Elige un idle al azar distinto del que está sonando.
func _play_random_idle() -> void:
	if idle_animations.is_empty():
		return

	var options := idle_animations.duplicate()
	options.erase(_anim.animation)
	if options.is_empty():
		options = idle_animations

	_anim.play(options.pick_random())


## Amague: hace el ademán de darse vuelta y se arrepiente.
func _play_glance() -> void:
	_is_busy = true
	_anim.play("amague")
	await _anim.animation_finished
	if _is_turned:
		return
	_is_busy = false
	_idle_timer = idle_change_interval
	_play_random_idle()


func _on_turned_around() -> void:
	if _is_turned:
		return
	_is_turned = true
	_is_busy = true
	_anim.play("darse_vuelta")


func _on_game_started() -> void:
	_is_turned = false
	_is_busy = false
	_suspicion = 0.0
	_idle_timer = idle_change_interval
	_glance_timer = glance_interval
	_play_random_idle()


func _on_suspicion_changed(value: float) -> void:
	_suspicion = value
