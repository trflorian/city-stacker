extends Button
## Toggles all game audio, draws a speaker icon.

const ICON_COLOR := Color.WHITE
const SHADOW_COLOR := Color(0, 0, 0, 0.2)


func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_NONE
	pressed.connect(Global.toggle_mute)
	Global.mute_changed.connect(func(_muted: bool) -> void: queue_redraw())


func _draw() -> void:
	_draw_icon(Vector2(0, 3), SHADOW_COLOR)
	_draw_icon(Vector2.ZERO, ICON_COLOR)


func _draw_icon(offset: Vector2, color: Color) -> void:
	var s := size.y
	var o := offset + Vector2(s * 0.05, 0)
	draw_colored_polygon(PackedVector2Array([
		o + Vector2(0.0, 0.33) * s,
		o + Vector2(0.2, 0.33) * s,
		o + Vector2(0.45, 0.1) * s,
		o + Vector2(0.45, 0.9) * s,
		o + Vector2(0.2, 0.67) * s,
		o + Vector2(0.0, 0.67) * s,
	]), color)
	var width := s * 0.06
	if Global.muted:
		var c := o + Vector2(0.75, 0.5) * s
		var r := s * 0.15
		draw_line(c + Vector2(-r, -r), c + Vector2(r, r), color, width, true)
		draw_line(c + Vector2(-r, r), c + Vector2(r, -r), color, width, true)
	else:
		var c := o + Vector2(0.45, 0.5) * s
		draw_arc(c, s * 0.2, -PI / 3.5, PI / 3.5, 16, color, width, true)
		draw_arc(c, s * 0.36, -PI / 3.2, PI / 3.2, 20, color, width, true)
