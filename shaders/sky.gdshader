shader_type canvas_item;
// Vertical sky gradient in screen space.

uniform vec4 top_color : source_color;
uniform vec4 bottom_color : source_color;

void fragment() {
	COLOR = mix(top_color, bottom_color, SCREEN_UV.y);
}
