shader_type canvas_item;

uniform vec4 vignette_rgb = vec4(0.0, 0.0, 0.0, 1.0);

void fragment(){
	float r = vignette_rgb.r;
	float g = vignette_rgb.g;
	float b = vignette_rgb.b;
	COLOR = vec4(r, g, b, UV.x * 0.7);
}