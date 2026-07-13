shader_type spatial;
// HD-2D 光照着色器 (用于3D场景)
// 模拟 Octopath Traveler 的柔和全局光照效果
// 结合像素艺术精灵和3D环境

render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D albedo_texture : hint_albedo;
uniform sampler2D normal_texture : hint_normal;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float pixel_grid : hint_range(0.0, 1.0) = 0.0;
// 环境光强度
uniform float ambient_intensity : hint_range(0.0, 2.0) = 0.6;
// 边缘光强度
uniform float rim_light : hint_range(0.0, 2.0) = 0.5;
// 边缘光颜色
uniform vec4 rim_color : source_color = vec4(1.0, 0.9, 0.7, 1.0);

void fragment() {
	vec4 albedo_tex = texture(albedo_texture, UV);
	ALBEDO = albedo_tex.rgb * albedo_color.rgb;

	// 法线贴图
	if (normal_texture != null) {
		NORMAL_MAP = texture(normal_texture, UV).rgb;
		NORMAL_MAP_DEPTH = 1.0;
	}

	ALPHA = albedo_tex.a * albedo_color.a;

	// 像素网格效果 (可选)
	if (pixel_grid > 0.0) {
		vec2 grid = fract(UV * SCREEN_PIXEL_SIZE * 32.0);
		if (grid.x < pixel_grid || grid.y < pixel_grid) {
			ALBEDO *= 0.85;
		}
	}

	// 环境光
	ALBEDO *= ambient_intensity + 0.4;
}

// 边缘光计算
void light() {
	vec3 view_dir = normalize(VIEW);
	float rim = 1.0 - max(dot(NORMAL, view_dir), 0.0);
	rim = smoothstep(0.5, 1.0, rim);
	DIFFUSE_LIGHT += rim * rim_light * rim_color.rgb;
}
