extends Node
## Autoload holding state that survives scene reloads: high score, title screen
## flag, mute setting and the background music player.

signal mute_changed(muted: bool)

const SAVE_PATH := "user://save.cfg"
const MUSIC_VOLUME := 0.3

var high_score := 0
## True after the first tap; the title screen is only shown once per app launch.
var started := false
var muted := false

var sfx_snap: AudioStreamWAV
var sfx_land: AudioStreamWAV

var _music_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load()
	AudioServer.set_bus_mute(0, muted)

	sfx_snap = Synth.snap()
	sfx_land = Synth.blop()

	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = linear_to_db(MUSIC_VOLUME)
	add_child(_music_player)
	# music takes a moment to synthesize, keep it off the main thread
	WorkerThreadPool.add_task(_generate_music)


func _unhandled_input(event: InputEvent) -> void:
	# exit on escape / android back button
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func submit_score(score: int) -> void:
	if score > high_score:
		high_score = score
		_save()


func toggle_mute() -> void:
	muted = not muted
	AudioServer.set_bus_mute(0, muted)
	mute_changed.emit(muted)
	_save()


func _generate_music() -> void:
	var stream := Synth.music()
	_start_music.call_deferred(stream)


func _start_music(stream: AudioStreamWAV) -> void:
	_music_player.stream = stream
	_music_player.play()


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
