extends Control
## In-game ui: title screen, score, high score and game over panel.

@export var game: Main

@onready var _title: Control = $Title
@onready var _instructions: Control = $Instructions
@onready var _score: SmallCapsLabel = $Scores/Score
@onready var _high_score: SmallCapsLabel = $Scores/HighScore
@onready var _scores: Control = $Scores
@onready var _game_over_panel: Control = $GameOverPanel
@onready var _restart_button: Button = $GameOverPanel/RestartButton


func _ready() -> void:
	game.tapped.connect(_on_tap)
	game.score_changed.connect(_on_score_changed)
	game.game_over.connect(_on_game_over)
	_restart_button.pressed.connect(get_tree().reload_current_scene)

	_game_over_panel.visible = false
	_update_scores()
	_set_show_in_game_state()

	# gently pulse the instructions on the title screen
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_instructions, "modulate:a", 0.55, 0.9)
	tween.tween_property(_instructions, "modulate:a", 1.0, 0.9)


func _on_tap() -> void:
	# only check first tap
	if Global.started:
		return
	Global.started = true
	_set_show_in_game_state()


func _set_show_in_game_state() -> void:
	_title.visible = not Global.started
	_instructions.visible = not Global.started
	_scores.visible = Global.started


func _update_scores() -> void:
	_score.label_text = "Score: %d" % game.score
	_high_score.label_text = "High Score: %d" % Global.high_score


func _on_score_changed(_score_value: int) -> void:
	_update_scores()
	_score.pivot_offset = _score.size / 2.0
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_score.scale = Vector2.ONE * 1.2
	tween.tween_property(_score, "scale", Vector2.ONE, 0.25)


func _on_game_over() -> void:
	_game_over_panel.visible = true
	_game_over_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_interval(0.4)
	tween.tween_property(_game_over_panel, "modulate:a", 1.0, 0.4)
