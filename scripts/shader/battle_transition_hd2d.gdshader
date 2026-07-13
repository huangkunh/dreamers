shader_type canvas_item;
// HD-2D 战斗过渡着色器
// 用于战斗开始和结束的戏剧化视觉效果

uniform sampler2D screen_texture : hint_screen_texture;

// 过渡进度 (0-1)
uniform float progress : hint_range(0.0, 1.0) = 0.0;
// 过渡类型 (0=战斗开始, 1=战斗结束, 2=战斗胜利)
uniform int transition_type : hint_range(0, 2) = 0;
// 闪烁强度
uniform float flash_intensity : hint_range(0.0, 3.0) = 1.5;
// 闪烁颜色
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// 噪声函数
float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
	vec2 i = floor(st);
	vec2 f = fract(st);
	
	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));
	
	vec2 u = f * f * (3.0 - 2.0 * f);
	
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = UV;
	vec4 color = texture(screen_texture, uv);
	
	// 闪烁效果
	float flash = 0.0;
	
	if (transition_type == 0) {
		// 战斗开始 - 白闪 + 径向模糊收缩
		flash = flash_intensity * pow(1.0 - progress, 2.0);
		
		// 径向扭曲
		float dist = distance(uv, vec2(0.5, 0.5));
		float radial_distort = 0.02 * (1.0 - progress) * dist;
		vec2 center_dir = normalize(uv - vec2(0.5, 0.5));
		uv += center_dir * radial_distort;
		
		// 边缘暗化
		color.rgb *= 1.0 - (1.0 - progress) * dist * 0.8;
		
	} else if (transition_type == 1) {
		// 战斗结束 - 径向模糊扩散
		float dist = distance(uv, vec2(0.5, 0.5));
		
		// 径向扭曲（反向）
		float radial_distort = 0.015 * progress * dist;
		vec2 center_dir = normalize(uv - vec2(0.5, 0.5));
		uv -= center_dir * radial_distort;
		
		// 中心高亮
		float center_glow = 1.0 - smoothstep(0.0, 0.5, dist);
		color.rgb += vec3(0.1, 0.08, 0.05) * center_glow * progress;
		
	} else {
		// 战斗胜利 - 金色光芒 + 粒子效果
		flash = flash_intensity * pow(1.0 - progress, 3.0) * 0.5;
		
		// 金色色调
		vec3 gold_tint = vec3(1.0, 0.9, 0.6);
		color.rgb = mix(color.rgb, color.rgb * gold_tint, progress * 0.3);
		
		// 添加噪声粒子效果
		float n = noise(uv * 10.0 + TIME * 2.0);
		if (n > 0.85) {
			color.rgb += vec3(0.2, 0.15, 0.05) * progress;
		}
		
		// 光芒放射
		float dist = distance(uv, vec2(0.5, 0.5));
		float ray_intensity = sin(atan(uv.y - 0.5, uv.x - 0.5) * 8.0 + TIME * 3.0) * 0.5 + 0.5;
		color.rgb += vec3(0.15, 0.12, 0.05) * ray_intensity * progress * (1.0 - dist);
	}
	
	// 应用闪光
	color.rgb = mix(color.rgb, flash_color.rgb, flash * flash_color.a);
	
	// 重新采样（如果UV被修改）
	if (transition_type != 2) {
		vec4 distorted_color = texture(screen_texture, uv);
		color.rgb = mix(color.rgb, distorted_color.rgb, 0.5);
	}
	
	COLOR = color;
}