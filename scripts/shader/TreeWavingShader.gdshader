shader_type spatial;

// 贴图
uniform sampler2D texture_albedo;  // 颜色贴图
uniform sampler2D texture_normal : hint_normal;  // 法线贴图

// 摇摆参数
uniform float sway_strength : hint_range(0.0, 0.05) = 0.01; // 摇摆强度
uniform float sway_speed : hint_range(0.0, 10.0) = 2.0;      // 摇摆速度
uniform float sway_frequency : hint_range(0.0, 10.0) = 5.0;  // 摇摆频率
uniform float sway_threshold : hint_range(0.0, 1.0) = 0.5;   // 摇摆阈值，决定摇摆开始的高度

void vertex() {
    // 计算左右（X 轴）和前后（Z 轴）摇动的偏移
    float sway_x = sin(TIME * sway_speed + UV.y * sway_frequency) * sway_strength;
    float sway_z = cos(TIME * sway_speed * 0.8 + UV.y * sway_frequency * 1.2) * sway_strength * 0.5;

    // 计算摇动权重（避免 if 语句）
    float sway_factor = smoothstep(sway_threshold, 1.0, VERTEX.y);

    // 应用摇动
    VERTEX.x += sway_x * sway_factor;
    VERTEX.z += sway_z * sway_factor;
}

void fragment() {
    // 从颜色贴图中采样颜色
    vec4 texColor = texture(texture_albedo, UV);

    // 从法线贴图中采样法线，并将其转换到 [-1,1] 的范围
    vec3 normal_map = texture(texture_normal, UV).rgb;
    normal_map = normal_map * 2.0 - 1.0;

    // 将法线贴图应用到当前法线
    NORMAL = normalize(TANGENT * normal_map.x + BINORMAL * normal_map.y + NORMAL * normal_map.z);

    // 设置输出颜色和透明度
    ALBEDO = texColor.rgb;
    ALPHA = texColor.a;
}
