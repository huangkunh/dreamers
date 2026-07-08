shader_type spatial;

uniform float wind_speed : hint_range(0.0, 10.0);
uniform float wind_strength : hint_range(0.0, 1.0);
uniform sampler2D tree_texture;

void vertex() {
    // 获取顶点的位置
    vec3 vertex_position = VERTEX;
    
    // 计算风的影响
    float wind_effect = sin(dot(vertex_position.xyz, vec3(1.0, 0.0, 1.0)) * wind_speed + TIME) * wind_strength;
    
    // 应用风的影响到顶点的Y轴
    vertex_position.y += vertex_position.y * wind_effect;
    
    // 更新顶点位置
    VERTEX = vertex_position;
}

void fragment() {
    // 从纹理中采样颜色
    vec4 tree_color = texture(tree_texture, UV);
    
    // 输出最终颜色
    ALBEDO = tree_color.rgb;
    ALPHA = tree_color.a;
}