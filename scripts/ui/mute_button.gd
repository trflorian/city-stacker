class_name MuteButton
extends Button
## Toggles all game audio. Draws a speaker icon with sound waves, or a cross when muted.

@export var palette: Palette


func _ready() -> void:
	pressed.connect(GameState.toggle_mute)
	GameState.mute_changed.connect(_on_mute_changed)


func _on_mute_changed(_muted: bool) -> void:
	queue_redraw()


func _draw() -> void:
	_draw_icon(palette.shadow_offset, palette.shadow)
	_draw_icon(Vector2.ZERO, palette.icon)


func _draw_icon(offset: Vector2, color: Color) -> void:
	var s := size.y
	var origin := offset + Vector2(s * 0.05, 0)
	var speaker := PackedVector2Array(
		[
			origin + Vector2(0.0, 0.33) * s,
			origin + Vector2(0.2, 0.33) * s,
			origin + Vector2(0.45, 0.1) * s,
			origin + Vector2(0.45, 0.9) * s,
			origin + Vector2(0.2, 0.67) * s,
			origin + Vector2(0.0, 0.67) * s,
		]
	)
	draw_colored_polygon(speaker, color)
	var width := s * 0.06
	if GameState.muted:
		var center := origin + Vector2(0.75, 0.5) * s
		var r := s * 0.15
		draw_line(center + Vector2(-r, -r), center + Vector2(r, r), color, width, true)
		draw_line(center + Vector2(-r, r), center + Vector2(r, -r), color, width, true)
	else:
		var center := origin + Vector2(0.45, 0.5) * s
		draw_arc(center, s * 0.2, -PI / 3.5, PI / 3.5, 16, color, width, true)
		draw_arc(center, s * 0.36, -PI / 3.2, PI / 3.2, 20, color, width, true)
