extends Node
## Máquina de estados del juego y score. Autoload.
## No toca nodos de escena: avisa por EventBus y cada sistema reacciona.

enum State { MENU, PLAYING, GAME_OVER }

var state: State = State.MENU
var score: int = 0


func _ready() -> void:
	EventBus.streamer_turned_around.connect(_on_streamer_turned_around)
	EventBus.disaster_resolved.connect(_on_disaster_resolved)


func is_playing() -> bool:
	return state == State.PLAYING


func start_game() -> void:
	state = State.PLAYING
	score = 0
	print("[GameManager] Partida iniciada.")
	EventBus.game_started.emit()


func end_game() -> void:
	if state != State.PLAYING:
		return
	state = State.GAME_OVER
	print("[GameManager] Game over. Score: ", score)
	EventBus.game_over.emit(score)


func _on_streamer_turned_around() -> void:
	end_game()


func _on_disaster_resolved(_disaster) -> void:
	if not is_playing():
		return
	score += 1
