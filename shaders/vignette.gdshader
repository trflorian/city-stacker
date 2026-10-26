shader_type canvas_item;
// Subtle vignette like the post processing of the original game.

uniform float intensity = 0.3;
uniform float smoothness = 0.55;
uniform vec3 tint : source_color = vec3(0.0, 0.05, 0.08);

void fragment() {
	float dist = length((SCREEN_UV - 0.5) * vec2(1.0, 0.8)) * 1.6;
	float vignette = smoothstep(1.0 - smoothness, 1.0 + smoothness * 0.5, dist);
	COLOR = vec4(tint, vignette * intensity);
}
