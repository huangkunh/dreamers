shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha, depth_draw_opaque;

uniform sampler2D albedo_texture : filter_nearest, source_color;
uniform sampler2D gradient_texture : filter_nearest, source_color; // Gradient texture
uniform float sway_strength : hint_range(0.0, 1.0) = 0.1;
uniform float sway_speed : hint_range(0.0, 5.0) = 1.0;
uniform float sway_frequency : hint_range(0.0, 10.0) = 3.0;

void vertex() {
    // Sample the gradient texture using UV coordinates
    vec4 gradient_color = texture(gradient_texture, VERTEX.yz);
    float influence = 1.0 - gradient_color.r; // Assume gradient is grayscale, so use the red channel

    // Calculate sway with influence from gradient
    float sway = sin(VERTEX.z * sway_frequency + TIME * sway_speed) * sway_strength * influence;
    VERTEX.x += sway;
}

void fragment() {
    vec4 albedo_color = texture(albedo_texture, UV);
    ALBEDO = albedo_color.rgb;
    ALPHA = albedo_color.a;
}
