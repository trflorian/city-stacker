class_name BackgroundMusic
extends AudioStreamPlayer
## Autoload playing the looping background music across scene reloads.

var _task_id := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.quitting.connect(stop)
	# the music takes a moment to synthesize, keep it off the main thread
	_task_id = WorkerThreadPool.add_task(_generate)


func _exit_tree() -> void:
	if _task_id >= 0:
		WorkerThreadPool.wait_for_task_completion(_task_id)
		_task_id = -1


func _generate() -> void:
	_start.call_deferred(Synth.music())


func _start(music: AudioStreamWAV) -> void:
	if _task_id >= 0:
		WorkerThreadPool.wait_for_task_completion(_task_id)
		_task_id = -1
	stream = music
	play()
