class_name Game
extends Node2D
## Root of the game scene. Handles input and score, and wires the crane, camera, boundaries and hud together.

## Areas that end the game when a house enters them.
@export var boundaries: Array[BoundaryArea] = []

var _score := 0
var _is_game_over := false

@onready var _crane: Crane = %Crane
@onready var _camera: GameCamera = %GameCamera
@onready var _hud: Hud = %Hud
@onready var _tap_player: AudioStreamPlayer = %TapPlayer


func _ready() -> void:
	_tap_player.stream = Synth.snap()

	_crane.house_landed.connect(_on_house_landed)
	_crane.house_fell.connect(_end_game)
	_crane.building_completed.connect(_end_game)
	for boundary in boundaries:
		boundary.house_entered.connect(_end_game)
	_hud.restart_requested.connect(get_tree().reload_current_scene)

	_hud.set_title_visible(not GameState.started)
	_hud.set_scores(_score, GameState.high_score)
	_crane.start()


func _unhandled_input(event: InputEvent) -> void:
	# only receives taps that were not handled by a ui button
	var mouse_event := event as InputEventMouseButton
	var is_tap := mouse_event != null and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
	if not (is_tap or event.is_action_pressed("ui_accept")) or _is_game_over:
		return
	get_viewport().set_input_as_handled()
	_tap_player.play()

	if not GameState.started:
		GameState.started = true
		_hud.set_title_visible(false)

	_crane.release_house()


func _on_house_landed() -> void:
	_score += 1
	GameState.submit_score(_score)
	_hud.set_scores(_score, GameState.high_score, true)


func _end_game() -> void:
	if _is_game_over:
		return
	_is_game_over = true
	_crane.stop()
	_camera.show_overview()
	_hud.show_game_over()
