class_name Hud
extends CanvasLayer
## In-game ui: title screen, score, high score, mute button and game over panel.

signal restart_requested

@export var instructions_pulse_alpha := 0.55
@export var instructions_pulse_time := 0.9
@export var score_pop_scale := 1.2

@onready var _title: SmallCapsLabel = %Title
@onready var _instructions: SmallCapsLabel = %Instructions
@onready var _scores: Control = %Scores
@onready var _score: SmallCapsLabel = %Score
@onready var _high_score: SmallCapsLabel = %HighScore
@onready var _game_over_panel: Control = %GameOverPanel
@onready var _restart_button: Button = %RestartButton


func _ready() -> void:
	_restart_button.pressed.connect(restart_requested.emit)
	_game_over_panel.visible = false

	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_instructions, "modulate:a", instructions_pulse_alpha, instructions_pulse_time)
	tween.tween_property(_instructions, "modulate:a", 1.0, instructions_pulse_time)


## Shows the title screen, or the in-game scores when hidden.
func set_title_visible(title_visible: bool) -> void:
	_title.visible = title_visible
	_instructions.visible = title_visible
	_scores.visible = not title_visible


func set_scores(score: int, high_score: int, animate := false) -> void:
	_score.label_text = "Score: %d" % score
	_high_score.label_text = "High Score: %d" % high_score
	if animate:
		_score.pivot_offset = _score.size / 2.0
		_score.scale = Vector2.ONE * score_pop_scale
		create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(
			_score, "scale", Vector2.ONE, 0.25
		)


func show_game_over() -> void:
	_game_over_panel.visible = true
	_game_over_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_interval(0.4)
	tween.tween_property(_game_over_panel, "modulate:a", 1.0, 0.4)
