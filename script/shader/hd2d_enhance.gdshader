shader_type canvas_item;
## HD-2D 像素艺术增强着色器
## 参考 Octopath Traveler 的像素渲染风格
## 保持像素清晰度的同时添加微妙的光影效果

uniform sampler2D screen_texture : hint_screen_texture;

// 像素化程度 (1.0=原始, 2.0=2倍像素, 等)
uniform float pixel_size : hint_range(0.25, 4.0) = 1.0;
// 边缘高光强度
uniform float edge_highlight : hint_range(0.0, 2.0) = 0.3;
// 饱和度增强
uniform float saturation_boost : hint_range(0.0, 2.0) = 1.1;
// 对比度
uniform float contrast : hint_range(0.5, 2.0) = 1.05;
// 色温偏移 (暖色=正, 冷色=负)
uniform float color_temperature : hint_range(-1.0, 1.0) = 0.1;

void fragment() {
	// 像素化采样
	vec2 pixel_uv = floor(UV * SCREEN_PIXEL_SIZE * pixel_size) / (SCREEN_PIXEL_SIZE * pixel_size);
	vec4 color = texture(screen_texture, pixel_uv);

	// 饱和度增强
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	color.rgb = mix(vec3(gray), color.rgb, saturation_boost);

	// 对比度
	color.rgb = (color.rgb - 0.5) * contrast + 0.5;

	// 色温调整
	if (color_temperature > 0.0) {
		color.r += color_temperature * 0.05;
		color.b -= color_temperature * 0.05;
	} else {
		color.r += color_temperature * 0.05;
		color.b -= color_temperature * 0.05;
	}

	// 边缘检测 (简单的Sobel)
	vec2 texel = 1.0 / SCREEN_PIXEL_SIZE;
	float left = dot(texture(screen_texture, pixel_uv - vec2(texel.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
	float right = dot(texture(screen_texture, pixel_uv + vec2(texel.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
	float top = dot(texture(screen_texture, pixel_uv - vec2(0.0, texel.y)).rgb, vec3(0.299, 0.587, 0.114));
	float bottom = dot(texture(screen_texture, pixel_uv + vec2(0.0, texel.y)).rgb, vec3(0.299, 0.587, 0.114));

	float edge = length(vec2(right - left, bottom - top));
	color.rgb += edge * edge_highlight * vec3(1.0, 0.95, 0.8);

	COLOR = color;
}
