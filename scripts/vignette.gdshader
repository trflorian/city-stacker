shader_type canvas_item;
// Subtle vignette and soft light in the center, like the original post processing.

uniform float intensity = 0.3;
uniform float smoothness = 0.55;

void fragment() {
	vec2 d = (SCREEN_UV - 0.5) * vec2(1.0, 0.8);
	float dist = length(d) * 1.6;
	float vignette = smoothstep(1.0 - smoothness, 1.0 + smoothness * 0.5, dist);
	COLOR = vec4(0.0, 0.05, 0.08, vignette * intensity);
}
