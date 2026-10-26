@tool
class_name SmallCapsLabel
extends RichTextLabel
## Centered label rendering lowercase letters as smaller capitals, like the
## small caps style of the original TextMesh Pro texts.

const SMALL_CAPS_SCALE := 0.8

@export var label_text := "":
	set(value):
		label_text = value
		_update()
@export var label_font_size := 80:
	set(value):
		label_font_size = value
		_update()


func _ready() -> void:
	bbcode_enabled = true
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update()


func _update() -> void:
	var small := int(label_font_size * SMALL_CAPS_SCALE)
	var result := "[center][font_size=%d]" % label_font_size
	var in_small := false
	for c in label_text:
		var is_lower := c != c.to_upper()
		if is_lower != in_small:
			result += "[font_size=%d]" % small if is_lower else "[/font_size]"
			in_small = is_lower
		result += c.to_upper()
	if in_small:
		result += "[/font_size]"
	text = result + "[/font_size][/center]"
