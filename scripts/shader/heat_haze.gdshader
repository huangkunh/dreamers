shader_type canvas_item;
// 热浪/热霾效果着色器
// 用于荒野场景的HD-2D视觉效果

uniform sampler2D screen_texture : hint_screen_texture;

// 扭曲强度
uniform float distortion_strength : hint_range(0.0, 10.0) = 3.0;
// 扭曲速度
uniform float distortion_speed : hint_range(0.1, 5.0) = 1.0;
// 扭曲频率
uniform float distortion_frequency : hint_range(1.0, 20.0) = 8.0;
// 扭曲方向 (0=水平, 1=垂直)
uniform float direction_bias : hint_range(0.0, 1.0) = 0.7;
// 垂直衰减 (越高扭曲越强)
uniform float vertical_falloff : hint_range(0.0, 2.0) = 0.5;

void fragment() {
	vec2 uv = UV;
	float time = TIME * distortion_speed;
	
	// 基础噪声 - 模拟热空气上升
	float noise_x = sin(uv.y * distortion_frequency + time) * cos(uv.x * distortion_frequency * 0.5 + time * 0.7);
	float noise_y = cos(uv.y * distortion_frequency * 0.8 + time * 0.9) * sin(uv.x * distortion_frequency * 0.3 + time * 0.6);
	
	// 混合方向偏移
	vec2 distortion = vec2(
		mix(noise_x, noise_y, direction_bias),
		mix(noise_y, noise_x * 0.3, direction_bias)
	);
	
	// 垂直衰减 - 越接近屏幕底部,扭曲越弱
	float vertical_factor = 1.0 - pow(1.0 - uv.y, vertical_falloff + 1.0);
	vertical_factor = clamp(vertical_factor, 0.0, 1.0);
	
	// 应用扭曲
	uv += distortion * distortion_strength * 0.001 * vertical_factor;
	
	// 采样屏幕纹理
	vec4 color = texture(screen_texture, uv);
	
	// 添加轻微的热霾色调 (温暖的橙黄色)
	float haze_intensity = vertical_factor * 0.08;
	color.rgb += vec3(0.02, 0.01, 0.0) * haze_intensity * distortion_strength;
	
	COLOR = color;
}