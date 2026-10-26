extends Node
## Autoload holding the state that survives scene reloads: high score, title screen flag and mute setting.

signal mute_changed(muted: bool)
## Emitted right before the game quits, audio players stop so no playback is left when the engine shuts down.
signal quitting

const SAVE_PATH := "user://save.cfg"
const MASTER_BUS := 0
## Seconds to wait between stopping audio and quitting, the audio server releases playbacks asynchronously.
const QUIT_DELAY := 0.1

var high_score := 0
## True after the first tap, the title screen is only shown once per app launch.
var started := false
var muted := false

var _is_quitting := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	_load()
	AudioServer.set_bus_mute(MASTER_BUS, muted)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		quit()


func quit() -> void:
	if _is_quitting:
		return
	_is_quitting = true
	quitting.emit()
	await get_tree().create_timer(QUIT_DELAY).timeout
	get_tree().quit()


func submit_score(score: int) -> void:
	if score > high_score:
		high_score = score
		_save()


func toggle_mute() -> void:
	muted = not muted
	AudioServer.set_bus_mute(MASTER_BUS, muted)
	mute_changed.emit(muted)
	_save()


func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	high_score = config.get_value("game", "high_score", 0)
	muted = config.get_value("audio", "muted", false)


func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("game", "high_score", high_score)
	config.set_value("audio", "muted", muted)
	config.save(SAVE_PATH)
