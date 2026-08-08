extends Node
## Máquina de estados del juego y score. Dueño: A.

enum State { MENU, PLAYING, GAME_OVER }

var state: State = State.MENU
var score: int = 0
