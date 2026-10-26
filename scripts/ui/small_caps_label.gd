@tool
class_name SmallCapsLabel
extends RichTextLabel
## Centered label that renders lowercase letters as smaller capitals, like the small caps style of the original
## TextMesh Pro texts.

@export var label_text := "":
	set(value):
		label_text = value
		_update_text()
@export var label_font_size := 80:
	set(value):
		label_font_size = value
		_update_text()
## Size of the lowercase letters relative to the font size.
@export var small_caps_scale := 0.8:
	set(value):
		small_caps_scale = value
		_update_text()


func _init() -> void:
	bbcode_enabled = true
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _update_text() -> void:
	var small_size := int(label_font_size * small_caps_scale)
	var result := "[center][font_size=%d]" % label_font_size
	var is_small := false
	for character in label_text:
		var is_lower := character != character.to_upper()
		if is_lower != is_small:
			result += "[font_size=%d]" % small_size if is_lower else "[/font_size]"
			is_small = is_lower
		result += character.to_upper()
	if is_small:
		result += "[/font_size]"
	text = result + "[/font_size][/center]"
