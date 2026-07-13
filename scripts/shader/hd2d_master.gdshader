shader_type canvas_item;
// HD-2D Master Shader - 综合后处理效果
// 集成景深、暗角、像素增强、色温调节于一体
// 参考 Octopath Traveler 的HD-2D视觉风格

uniform sampler2D screen_texture : hint_screen_texture;

// === 景深/移轴参数 ===
uniform float blur_strength : hint_range(0.0, 8.0) = 2.5;
uniform float blur_radius : hint_range(0.0, 1.0) = 0.35;
uniform float center_focus : hint_range(0.0, 1.0) = 0.5;
uniform int blur_iterations : hint_range(1, 8) = 3;

// === 暗角参数 ===
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.6;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.02, 1.0);
uniform float vignette_smoothness : hint_range(0.1, 1.0) = 0.5;

// === 像素增强参数 ===
uniform float pixel_size : hint_range(0.5, 4.0) = 1.0;
uniform float edge_highlight : hint_range(0.0, 1.5) = 0.25;
uniform float saturation_boost : hint_range(0.5, 2.0) = 1.08;
uniform float contrast : hint_range(0.5, 2.0) = 1.1;
uniform float color_temperature : hint_range(-0.5, 0.5) = 0.12;

// === 色调映射 ===
uniform float exposure : hint_range(0.5, 2.0) = 1.1;
uniform float gamma : hint_range(0.8, 1.4) = 1.05;

// 景深模糊采样
vec4 bokeh_blur(sampler2D tex, vec2 uv, float radius) {
	vec4 color = vec4(0.0);
	float total = 0.0;
	
	// 六边形采样模式 - 模拟相机镜头
	vec2 offsets[6] = vec2[](
		vec2(1.0, 0.0),
		vec2(0.5, 0.866),
		vec2(-0.5, 0.866),
		vec2(-1.0, 0.0),
		vec2(-0.5, -0.866),
		vec2(0.5, -0.866)
	);
	
	for (int i = 0; i < 6; i++) {
		for (float r = 1.0; r <= float(blur_iterations); r += 1.0) {
			vec2 offset = offsets[i] * radius * r / 300.0;
			color += texture(tex, uv + offset);
			color += texture(tex, uv - offset);
			total += 2.0;
		}
	}
	
	// 中心采样
	color += texture(tex, uv);
	total += 1.0;
	
	return color / total;
}

void fragment() {
	vec2 uv = UV;
	
	// === 1. 像素化采样 ===
	vec2 pixel_uv = floor(uv * SCREEN_PIXEL_SIZE * pixel_size) / (SCREEN_PIXEL_SIZE * pixel_size);
	vec4 color = texture(screen_texture, pixel_uv);
	
	// === 2. 景深/移轴效果 ===
	float dist = distance(uv, vec2(0.5, center_focus));
	
	if (dist > blur_radius) {
		float blur_amount = (dist - blur_radius) / (1.0 - blur_radius);
		blur_amount = pow(blur_amount, 1.5); // 平滑过渡
		blur_amount = clamp(blur_amount, 0.0, 1.0);
		
		float radius = blur_amount * blur_strength;
		vec4 blur_color = bokeh_blur(screen_texture, pixel_uv, radius);
		color = mix(color, blur_color, blur_amount * 0.75);
	}
	
	// === 3. 暗角效果 ===
	float vignette = 1.0 - smoothstep(
		blur_radius - vignette_smoothness,
		1.0,
		dist
	);
	vignette = mix(1.0, vignette, vignette_intensity);
	color.rgb = mix(color.rgb, color.rgb * vignette_color.rgb, (1.0 - vignette) * vignette_intensity * 0.5);
	color.rgb *= vignette;
	
	// === 4. 色彩增强 ===
	// 饱和度
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	color.rgb = mix(vec3(gray), color.rgb, saturation_boost);
	
	// 对比度
	color.rgb = (color.rgb - 0.5) * contrast + 0.5;
	
	// === 5. 色温调整 ===
	// 暖色调
	vec3 warm_tint = vec3(1.0, 0.95, 0.88);
	// 冷色调
	vec3 cool_tint = vec3(0.88, 0.95, 1.0);
	
	if (color_temperature > 0.0) {
		color.rgb = mix(color.rgb, color.rgb * warm_tint, color_temperature);
		color.r += color_temperature * 0.03;
		color.b -= color_temperature * 0.02;
	} else {
		color.rgb = mix(color.rgb, color.rgb * cool_tint, -color_temperature);
		color.r += color_temperature * 0.02;
		color.b -= color_temperature * 0.03;
	}
	
	// === 6. 边缘高光 ===
	vec2 texel = 1.0 / SCREEN_PIXEL_SIZE;
	float left = dot(texture(screen_texture, pixel_uv - vec2(texel.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
	float right = dot(texture(screen_texture, pixel_uv + vec2(texel.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
	float top = dot(texture(screen_texture, pixel_uv - vec2(0.0, texel.y)).rgb, vec3(0.299, 0.587, 0.114));
	float bottom = dot(texture(screen_texture, pixel_uv + vec2(0.0, texel.y)).rgb, vec3(0.299, 0.587, 0.114));
	
	float edge = length(vec2(right - left, bottom - top));
	color.rgb += edge * edge_highlight * vec3(1.0, 0.97, 0.92);
	
	// === 7. 色调映射 ===
	color.rgb *= exposure;
	color.rgb = color.rgb / (color.rgb + vec3(1.0)); // ACES Filmic
	color.rgb = pow(color.rgb, vec3(1.0 / gamma));
	
	// 输出
	COLOR = color;
}