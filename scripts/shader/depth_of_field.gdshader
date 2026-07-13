shader_type canvas_item;
// HD-2D 景深/移轴着色器 (Depth of Field / Tilt-Shift)
// 模拟八方旅人风格的景深效果 - 画面边缘模糊，中心清晰

uniform float blur_strength : hint_range(0.0, 10.0) = 2.0;
uniform float blur_radius : hint_range(0.0, 1.0) = 0.4;
uniform float center_focus : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.8;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	// 计算距离中心的距离
	float dist = distance(UV, vec2(0.5, center_focus));

	// 景深模糊 - 边缘模糊
	if (dist > blur_radius) {
		float blur_amount = (dist - blur_radius) / (1.0 - blur_radius);
		blur_amount = clamp(blur_amount, 0.0, 1.0);

		// 简单的模糊采样
		vec2 texel_size = 1.0 / SCREEN_PIXEL_SIZE;
		vec4 blur_color = vec4(0.0);
		float total = 0.0;
		float radius = blur_amount * blur_strength;

		for (float x = -2.0; x <= 2.0; x += 1.0) {
			for (float y = -2.0; y <= 2.0; y += 1.0) {
				vec2 offset = vec2(x, y) * radius / texel_size;
				blur_color += texture(TEXTURE, UV + offset);
				total += 1.0;
			}
		}
		blur_color /= total;
		color = mix(color, blur_color, blur_amount * 0.7);
	}

	// 暗角效果
	float vignette = 1.0 - dist * vignette_intensity;
	vignette = clamp(vignette, 0.0, 1.0);
	color.rgb = mix(color.rgb, color.rgb * vignette_color.rgb, vignette_intensity * (1.0 - vignette));

	COLOR = color;
}
