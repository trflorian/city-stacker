class_name Main
extends Node2D
## Core game manager: input, score and game over state.

signal tapped
signal game_over
signal score_changed(score: int)

## Pixels per world unit. Gameplay constants are in world units like the
## original Unity version; 10 units fit the 1280px tall viewport.
const UNIT := 128.0

var score := 0
var house_color_id := 0
var is_game_over := false

@onready var _snap_player: AudioStreamPlayer = $SnapPlayer


func _ready() -> void:
	house_color_id = randi() % House.FACADE_COLORS.size()
	_snap_player.stream = Global.sfx_snap


func _unhandled_input(event: InputEvent) -> void:
	# only receives taps that were not consumed by a ui button
	var pressed: bool = (event is InputEventMouseButton and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT) or event.is_action_pressed("ui_accept")
	if pressed and not is_game_over:
		get_viewport().set_input_as_handled()
		_snap_player.play()
		tapped.emit()


func call_game_over() -> void:
	# dont call game over event a second time
	if is_game_over:
		return
	is_game_over = true
	game_over.emit()


func increase_score() -> void:
	score += 1
	Global.submit_score(score)
	score_changed.emit(score)
