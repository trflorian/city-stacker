class_name MuteButton
extends Button
## Toggles all game audio. Shows a speaker icon with a flat drop shadow.

@export var palette: Palette
@export var sound_on_texture: Texture2D
@export var sound_off_texture: Texture2D


func _ready() -> void:
	pressed.connect(GameState.toggle_mute)
	GameState.mute_changed.connect(_on_mute_changed)


func _on_mute_changed(_muted: bool) -> void:
	queue_redraw()


func _draw() -> void:
	var texture := sound_off_texture if GameState.muted else sound_on_texture
	var rect := Rect2(Vector2.ZERO, size)
	draw_texture_rect(texture, Rect2(rect.position + palette.shadow_offset, rect.size), false, palette.shadow)
	draw_texture_rect(texture, rect, false)
