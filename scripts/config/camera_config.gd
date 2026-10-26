class_name CameraConfig
extends Resource
## Tuning of the camera that follows the crane.

## Distance the camera stays below its target in world units.
@export var follow_offset := 7.5
## How fast the camera catches up with its target.
@export var follow_speed := 3.0
## Half of the visible height in world units at zoom level 1.
@export var view_half_height := 5.0
## Duration of the zoom out to the whole building on game over in seconds.
@export var overview_zoom_time := 1.0
