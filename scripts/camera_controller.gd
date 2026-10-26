extends Camera2D
## Follows the crane and zooms out to show the whole building on game over.

const CRANE_CAMERA_OFFSET := 1.5
const GAME_OVER_ZOOM_TIME := 1.0
const VIEW_HEIGHT := 5.0

@export var game: Main
@export var crane: Crane

var _is_game_over := false


func _ready() -> void:
	game.game_over.connect(_on_game_over)


func _process(delta: float) -> void:
	if _is_game_over:
		return
	var target := crane.position + Vector2(0, (Crane.CRANE_LENGTH + CRANE_CAMERA_OFFSET) * Main.UNIT)
	position = position.lerp(target, minf(delta * 3.0, 1.0))


func _on_game_over() -> void:
	_is_game_over = true
	var reached_height := maxf(-position.y / Main.UNIT, 0.0)
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", -reached_height / 2.0 * Main.UNIT, GAME_OVER_ZOOM_TIME)
	tween.tween_property(self, "zoom", Vector2.ONE * VIEW_HEIGHT / (VIEW_HEIGHT + reached_height),
			GAME_OVER_ZOOM_TIME)
