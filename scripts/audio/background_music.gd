class_name BackgroundMusic
extends AudioStreamPlayer
## Autoload playing the looping background music across scene reloads.


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# stop before the engine shuts down so the looping playback is released cleanly
	GameState.quitting.connect(stop)
