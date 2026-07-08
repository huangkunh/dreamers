shader_type spatial;
uniform sampler2D noise;
uniform float threshold : hint_range(0.0, 1.0) = 0.5;
uniform float speed : hint_range(0.0, 16.0) = 1.0;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform float turbulence_frequency = 8.0;
uniform float turbulence_amplitude : hint_range(0.0, .5) = .05;
uniform float turbulence_speed = 3.0;

void vertex()
{
	UV = (UV * uv_scale) + TIME * speed;
}

void fragment(){
	vec2 uv = UV + vec2(
		sin(UV.y * turbulence_frequency + TIME * turbulence_speed ) * turbulence_amplitude,
		cos(UV.x * turbulence_frequency + TIME * turbulence_speed ) * turbulence_amplitude
	);
	ALPHA = texture(noise, uv).r;
	ALPHA_SCISSOR_THRESHOLD = threshold;
}