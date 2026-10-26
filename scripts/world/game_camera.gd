class_name GameCamera
extends Camera2D
## Follows its target and zooms out to show the whole building on game over.

@export var config: CameraConfig
@export var target: Node2D

var _is_following := true


func _process(delta: float) -> void:
	if not _is_following or target == null:
		return
	var goal := target.position + Vector2(0, Units.to_pixels(config.follow_offset))
	position = position.lerp(goal, minf(delta * config.follow_speed, 1.0))


## Stops following and zooms out so everything between the ground and the current height is visible.
func show_overview() -> void:
	_is_following = false
	var reached_height := maxf(-position.y / Units.PIXELS_PER_UNIT, 0.0)
	var zoom_level := config.view_half_height / (config.view_half_height + reached_height)
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y / 2.0, config.overview_zoom_time)
	tween.tween_property(self, "zoom", Vector2.ONE * zoom_level, config.overview_zoom_time)
