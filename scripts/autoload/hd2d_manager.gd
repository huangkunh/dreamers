extends Node
## HD-2D后处理管理器 (Hd2dManager)
## 集中管理HD-2D风格的屏幕后处理效果
## 包括：暗角、景深/移轴、像素增强、热浪扭曲
## 作为 Autoload 单例运行，跨场景持久化
## 参考 Octopath Traveler 的像素渲染风格

## 着色器资源
const VIGNETTE_SHADER := preload("res://scripts/shader/vignette.gdshader")
const DOF_SHADER := preload("res://scripts/shader/depth_of_field.gdshader")
const PIXEL_ENHANCE_SHADER := preload("res://scripts/shader/hd2d_enhance.gdshader")
const HEAT_HAZE_SHADER := preload("res://scripts/shader/heat_haze.gdshader")
const HD2D_MASTER_SHADER := preload("res://scripts/shader/hd2d_master.gdshader")
const BATTLE_TRANSITION_SHADER := preload("res://scripts/shader/battle_transition_hd2d.gdshader")

## 预设名称常量
enum Preset {
	CITY,       # 城镇 - 暖色、柔和景深
	WASTELAND,  # 荒野 - 强烈暗角、热浪扭曲
	DUNGEON,    # 地牢 - 暗色、紧凑景深
	BATTLE,     # 战斗 - 戏剧化、闪光效果
	TITLE,      # 标题 - 柔和、电影感
}

## 当前激活的预设
var current_preset: Preset = Preset.CITY
## 管理器是否启用（设为false时场景可使用自己的叠加层）
var enabled: bool = true
## CanvasLayer 层级（确保在最上层）
var _canvas_layer: CanvasLayer
## 暗角叠加层
var _vignette_rect: ColorRect
## 景深/移轴叠加层
var _dof_rect: ColorRect
## 像素增强叠加层
var _pixel_rect: ColorRect
## 热浪扭曲叠加层
var _haze_rect: ColorRect
## HD-2D Master叠加层 (综合效果)
var _master_rect: ColorRect
## 战斗过渡叠加层
var _battle_transition_rect: ColorRect
## 当前过渡Tween
var _transition_tween: Tween
## 视口大小缓存
var _viewport_size: Vector2i

## ===== 预设参数定义 =====

## 预设参数结构:
## vignette_intensity, vignette_opacity, vignette_rgb,
## dof_blur_strength, dof_blur_radius, dof_center_focus, dof_vignette_intensity,
## pixel_enabled, pixel_size, pixel_edge_highlight, pixel_saturation_boost, pixel_contrast, pixel_color_temperature,
## haze_enabled, haze_distortion_strength, haze_distortion_speed, haze_distortion_frequency

## 城镇预设参数 - 暖色、柔和景深
const _PRESET_CITY := {
	"vignette_intensity": 0.4,
	"vignette_opacity": 0.5,
	"vignette_rgb": Color(0.0, 0.0, 0.0, 1.0),
	"dof_blur_strength": 2.0,
	"dof_blur_radius": 0.4,
	"dof_center_focus": 0.5,
	"dof_vignette_intensity": 0.6,
	"pixel_enabled": true,
	"pixel_size": 1.0,
	"pixel_edge_highlight": 0.3,
	"pixel_saturation_boost": 1.1,
	"pixel_contrast": 1.05,
	"pixel_color_temperature": 0.15,
	"haze_enabled": false,
	"haze_distortion_strength": 0.0,
	"haze_distortion_speed": 1.0,
	"haze_distortion_frequency": 8.0,
}

## 荒野预设参数 - 强烈暗角、热浪扭曲
const _PRESET_WASTELAND := {
	"vignette_intensity": 0.55,
	"vignette_opacity": 0.65,
	"vignette_rgb": Color(0.1, 0.05, 0.0, 1.0),
	"dof_blur_strength": 2.5,
	"dof_blur_radius": 0.35,
	"dof_center_focus": 0.45,
	"dof_vignette_intensity": 0.9,
	"pixel_enabled": true,
	"pixel_size": 1.0,
	"pixel_edge_highlight": 0.25,
	"pixel_saturation_boost": 1.15,
	"pixel_contrast": 1.1,
	"pixel_color_temperature": 0.25,
	"haze_enabled": true,
	"haze_distortion_strength": 3.5,
	"haze_distortion_speed": 1.2,
	"haze_distortion_frequency": 10.0,
}

## 地牢预设参数 - 暗色、紧凑景深
const _PRESET_DUNGEON := {
	"vignette_intensity": 0.65,
	"vignette_opacity": 0.7,
	"vignette_rgb": Color(0.0, 0.0, 0.05, 1.0),
	"dof_blur_strength": 3.0,
	"dof_blur_radius": 0.3,
	"dof_center_focus": 0.5,
	"dof_vignette_intensity": 1.0,
	"pixel_enabled": true,
	"pixel_size": 1.0,
	"pixel_edge_highlight": 0.35,
	"pixel_saturation_boost": 0.95,
	"pixel_contrast": 1.15,
	"pixel_color_temperature": -0.1,
	"haze_enabled": false,
	"haze_distortion_strength": 0.0,
	"haze_distortion_speed": 1.0,
	"haze_distortion_frequency": 8.0,
}

## 战斗预设参数 - 戏剧化、高对比
const _PRESET_BATTLE := {
	"vignette_intensity": 0.5,
	"vignette_opacity": 0.6,
	"vignette_rgb": Color(0.05, 0.0, 0.0, 1.0),
	"dof_blur_strength": 3.5,
	"dof_blur_radius": 0.35,
	"dof_center_focus": 0.5,
	"dof_vignette_intensity": 1.2,
	"pixel_enabled": true,
	"pixel_size": 1.0,
	"pixel_edge_highlight": 0.4,
	"pixel_saturation_boost": 1.2,
	"pixel_contrast": 1.2,
	"pixel_color_temperature": 0.05,
	"haze_enabled": false,
	"haze_distortion_strength": 0.0,
	"haze_distortion_speed": 1.0,
	"haze_distortion_frequency": 8.0,
}

## 标题预设参数 - 柔和、电影感
const _PRESET_TITLE := {
	"vignette_intensity": 0.35,
	"vignette_opacity": 0.4,
	"vignette_rgb": Color(0.0, 0.0, 0.0, 1.0),
	"dof_blur_strength": 1.5,
	"dof_blur_radius": 0.45,
	"dof_center_focus": 0.5,
	"dof_vignette_intensity": 0.5,
	"pixel_enabled": true,
	"pixel_size": 1.0,
	"pixel_edge_highlight": 0.2,
	"pixel_saturation_boost": 1.05,
	"pixel_contrast": 1.0,
	"pixel_color_temperature": 0.08,
	"haze_enabled": false,
	"haze_distortion_strength": 0.0,
	"haze_distortion_speed": 1.0,
	"haze_distortion_frequency": 8.0,
}

func _ready() -> void:
	# 创建CanvasLayer和叠加层节点
	_create_overlay_nodes()
	# 监听视口大小变化
	_viewport_size = get_viewport().get_size()
	get_viewport().size_changed.connect(_on_viewport_resized)
	# 默认应用城镇预设
	apply_preset(Preset.CITY)

## 创建叠加层节点结构
func _create_overlay_nodes() -> void:
	# CanvasLayer确保绘制在最上层
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 100
	_canvas_layer.name = "Hd2dOverlay"
	add_child(_canvas_layer)

	# HD-2D Master叠加层 (综合效果，默认启用)
	_master_rect = _create_shader_rect("HD2DMaster", HD2D_MASTER_SHADER)
	_canvas_layer.add_child(_master_rect)
	
	# 战斗过渡叠加层 (默认隐藏)
	_battle_transition_rect = _create_shader_rect("BattleTransition", BATTLE_TRANSITION_SHADER)
	_canvas_layer.add_child(_battle_transition_rect)

	# 像素增强叠加层（最先处理，最底层）
	_pixel_rect = _create_shader_rect("PixelEnhance", PIXEL_ENHANCE_SHADER)
	_canvas_layer.add_child(_pixel_rect)

	# 景深/移轴叠加层
	_dof_rect = _create_shader_rect("DepthOfField", DOF_SHADER)
	_canvas_layer.add_child(_dof_rect)

	# 热浪扭曲叠加层
	_haze_rect = _create_shader_rect("HeatHaze", HEAT_HAZE_SHADER)
	_canvas_layer.add_child(_haze_rect)

	# 暗角叠加层（最顶层）
	_vignette_rect = _create_shader_rect("Vignette", VIGNETTE_SHADER)
	_canvas_layer.add_child(_vignette_rect)

## 创建带着色器的全屏ColorRect
func _create_shader_rect(name: String, shader: Shader) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = name
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	# 初始状态隐藏
	rect.visible = false
	return rect

## 视口大小变化回调
func _on_viewport_resized() -> void:
	_viewport_size = get_viewport().get_size()

## 获取预设参数字典
func _get_preset_params(preset: Preset) -> Dictionary:
	match preset:
		Preset.CITY:
			return _PRESET_CITY
		Preset.WASTELAND:
			return _PRESET_WASTELAND
		Preset.DUNGEON:
			return _PRESET_DUNGEON
		Preset.BATTLE:
			return _PRESET_BATTLE
		Preset.TITLE:
			return _PRESET_TITLE
	return _PRESET_CITY

## ===== 公共API =====

## 应用预设（立即切换，无过渡）
func apply_preset(preset: Preset) -> void:
	if not enabled:
		return
	current_preset = preset
	var params: Dictionary = _get_preset_params(preset)
	_apply_params_immediate(params)

## 应用预设（字符串版本，方便外部调用）
func apply_preset_by_name(preset_name: String) -> void:
	var preset: Preset = _preset_from_string(preset_name)
	apply_preset(preset)

## 平滑过渡到预设
func fade_to_preset(preset: Preset, duration: float = 0.5) -> void:
	if not enabled:
		return
	# 终止当前过渡
	_kill_tween()
	current_preset = preset
	var target_params: Dictionary = _get_preset_params(preset)
	_tween_params(target_params, duration)

## 平滑过渡到预设（字符串版本）
func fade_to_preset_by_name(preset_name: String, duration: float = 0.5) -> void:
	var preset: Preset = _preset_from_string(preset_name)
	fade_to_preset(preset, duration)

## 设置暗角效果
func set_vignette(intensity: float, color: Color = Color(0.0, 0.0, 0.0, 1.0)) -> void:
	if not enabled:
		return
	_vignette_rect.visible = true
	var mat: ShaderMaterial = _vignette_rect.material as ShaderMaterial
	mat.set_shader_parameter("vignette_intensity", intensity)
	mat.set_shader_parameter("vignette_rgb", color)

## 设置景深/移轴效果
func set_dof(strength: float, radius: float = 0.4, center: float = 0.5) -> void:
	if not enabled:
		return
	_dof_rect.visible = true
	var mat: ShaderMaterial = _dof_rect.material as ShaderMaterial
	mat.set_shader_parameter("blur_strength", strength)
	mat.set_shader_parameter("blur_radius", radius)
	mat.set_shader_parameter("center_focus", center)

## 设置像素增强效果
func set_pixel_enhance(is_enabled: bool, pixel_size: float = 1.0) -> void:
	if not enabled:
		return
	_pixel_rect.visible = is_enabled
	if is_enabled:
		var mat: ShaderMaterial = _pixel_rect.material as ShaderMaterial
		mat.set_shader_parameter("pixel_size", pixel_size)

## 设置色温偏移
func set_color_temperature(temp: float) -> void:
	if not enabled:
		return
	if not _pixel_rect.visible:
		_pixel_rect.visible = true
	var mat: ShaderMaterial = _pixel_rect.material as ShaderMaterial
	mat.set_shader_parameter("color_temperature", temp)

## 设置热浪扭曲效果
func set_heat_haze(is_enabled: bool, strength: float = 3.0) -> void:
	if not enabled:
		return
	_haze_rect.visible = is_enabled
	if is_enabled:
		var mat: ShaderMaterial = _haze_rect.material as ShaderMaterial
		mat.set_shader_parameter("distortion_strength", strength)

## 启用/禁用管理器（禁用后场景可使用自己的叠加层）
func set_enabled(is_enabled: bool) -> void:
	enabled = is_enabled
	_canvas_layer.visible = is_enabled

## 获取当前预设名称（中文描述）
func get_preset_description() -> String:
	match current_preset:
		Preset.CITY:
			return "城镇 - 暖色柔和"
		Preset.WASTELAND:
			return "荒野 - 炎热荒凉"
		Preset.DUNGEON:
			return "地牢 - 暗色紧凑"
		Preset.BATTLE:
			return "战斗 - 戏剧化"
		Preset.TITLE:
			return "标题 - 电影感"
	return "未知"

## ===== 内部实现 =====

## 立即应用参数
func _apply_params_immediate(params: Dictionary) -> void:
	# 暗角
	_vignette_rect.visible = true
	var v_mat: ShaderMaterial = _vignette_rect.material as ShaderMaterial
	v_mat.set_shader_parameter("vignette_intensity", params.get("vignette_intensity", 0.4))
	v_mat.set_shader_parameter("vignette_opacity", params.get("vignette_opacity", 0.5))
	v_mat.set_shader_parameter("vignette_rgb", params.get("vignette_rgb", Color(0.0, 0.0, 0.0, 1.0)))

	# 景深
	_dof_rect.visible = true
	var d_mat: ShaderMaterial = _dof_rect.material as ShaderMaterial
	d_mat.set_shader_parameter("blur_strength", params.get("dof_blur_strength", 2.0))
	d_mat.set_shader_parameter("blur_radius", params.get("dof_blur_radius", 0.4))
	d_mat.set_shader_parameter("center_focus", params.get("dof_center_focus", 0.5))
	d_mat.set_shader_parameter("vignette_intensity", params.get("dof_vignette_intensity", 0.8))

	# 像素增强
	_pixel_rect.visible = params.get("pixel_enabled", true)
	if _pixel_rect.visible:
		var p_mat: ShaderMaterial = _pixel_rect.material as ShaderMaterial
		p_mat.set_shader_parameter("pixel_size", params.get("pixel_size", 1.0))
		p_mat.set_shader_parameter("edge_highlight", params.get("pixel_edge_highlight", 0.3))
		p_mat.set_shader_parameter("saturation_boost", params.get("pixel_saturation_boost", 1.1))
		p_mat.set_shader_parameter("contrast", params.get("pixel_contrast", 1.05))
		p_mat.set_shader_parameter("color_temperature", params.get("pixel_color_temperature", 0.1))

	# 热浪扭曲
	_haze_rect.visible = params.get("haze_enabled", false)
	if _haze_rect.visible:
		var h_mat: ShaderMaterial = _haze_rect.material as ShaderMaterial
		h_mat.set_shader_parameter("distortion_strength", params.get("haze_distortion_strength", 3.0))
		h_mat.set_shader_parameter("distortion_speed", params.get("haze_distortion_speed", 1.0))
		h_mat.set_shader_parameter("distortion_frequency", params.get("haze_distortion_frequency", 8.0))

## 使用Tween平滑过渡参数
func _tween_params(target_params: Dictionary, duration: float) -> void:
	_transition_tween = create_tween()
	_transition_tween.set_parallel(true)

	# 暗角过渡
	_vignette_rect.visible = true
	var v_mat: ShaderMaterial = _vignette_rect.material as ShaderMaterial
	_tween_shader_param(v_mat, "vignette_intensity", target_params.get("vignette_intensity", 0.4), duration)
	_tween_shader_param(v_mat, "vignette_opacity", target_params.get("vignette_opacity", 0.5), duration)

	# 景深过渡
	_dof_rect.visible = true
	var d_mat: ShaderMaterial = _dof_rect.material as ShaderMaterial
	_tween_shader_param(d_mat, "blur_strength", target_params.get("dof_blur_strength", 2.0), duration)
	_tween_shader_param(d_mat, "blur_radius", target_params.get("dof_blur_radius", 0.4), duration)
	_tween_shader_param(d_mat, "center_focus", target_params.get("dof_center_focus", 0.5), duration)
	_tween_shader_param(d_mat, "vignette_intensity", target_params.get("dof_vignette_intensity", 0.8), duration)

	# 像素增强过渡
	var pixel_should_enable: bool = target_params.get("pixel_enabled", true)
	if _pixel_rect.visible and pixel_should_enable:
		var p_mat: ShaderMaterial = _pixel_rect.material as ShaderMaterial
		_tween_shader_param(p_mat, "edge_highlight", target_params.get("pixel_edge_highlight", 0.3), duration)
		_tween_shader_param(p_mat, "saturation_boost", target_params.get("pixel_saturation_boost", 1.1), duration)
		_tween_shader_param(p_mat, "contrast", target_params.get("pixel_contrast", 1.05), duration)
		_tween_shader_param(p_mat, "color_temperature", target_params.get("pixel_color_temperature", 0.1), duration)
	elif not _pixel_rect.visible and pixel_should_enable:
		# 从隐藏到显示：先设参数再显示
		_pixel_rect.visible = true
		_apply_pixel_params(target_params)

	# 热浪扭曲过渡
	var haze_should_enable: bool = target_params.get("haze_enabled", false)
	if _haze_rect.visible and haze_should_enable:
		var h_mat: ShaderMaterial = _haze_rect.material as ShaderMaterial
		_tween_shader_param(h_mat, "distortion_strength", target_params.get("haze_distortion_strength", 3.0), duration)
		_tween_shader_param(h_mat, "distortion_speed", target_params.get("haze_distortion_speed", 1.0), duration)
		_tween_shader_param(h_mat, "distortion_frequency", target_params.get("haze_distortion_frequency", 8.0), duration)
	elif not _haze_rect.visible and haze_should_enable:
		_haze_rect.visible = true
		_apply_haze_params(target_params)

	# 过渡完成后切换可见性
	_transition_tween.set_parallel(false)
	_transition_tween.tween_callback(func(): _finalize_visibility(target_params))

## Tween单个着色器参数
func _tween_shader_param(mat: ShaderMaterial, param_name: String, target_value: float, duration: float) -> void:
	var current_value: float = mat.get_shader_parameter(param_name) as float
	if is_equal_approx(current_value, target_value):
		return
	# 创建属性路径用于Tween: mat:shader_param/param_name
	_transition_tween.tween_method(
		func(val: float) -> void: mat.set_shader_parameter(param_name, val),
		current_value,
		target_value,
		duration
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

## 立即应用像素增强参数
func _apply_pixel_params(params: Dictionary) -> void:
	var p_mat: ShaderMaterial = _pixel_rect.material as ShaderMaterial
	p_mat.set_shader_parameter("pixel_size", params.get("pixel_size", 1.0))
	p_mat.set_shader_parameter("edge_highlight", params.get("pixel_edge_highlight", 0.3))
	p_mat.set_shader_parameter("saturation_boost", params.get("pixel_saturation_boost", 1.1))
	p_mat.set_shader_parameter("contrast", params.get("pixel_contrast", 1.05))
	p_mat.set_shader_parameter("color_temperature", params.get("pixel_color_temperature", 0.1))

## 立即应用热浪参数
func _apply_haze_params(params: Dictionary) -> void:
	var h_mat: ShaderMaterial = _haze_rect.material as ShaderMaterial
	h_mat.set_shader_parameter("distortion_strength", params.get("haze_distortion_strength", 3.0))
	h_mat.set_shader_parameter("distortion_speed", params.get("haze_distortion_speed", 1.0))
	h_mat.set_shader_parameter("distortion_frequency", params.get("haze_distortion_frequency", 8.0))

## 过渡完成后切换可见性
func _finalize_visibility(params: Dictionary) -> void:
	_pixel_rect.visible = params.get("pixel_enabled", true)
	_haze_rect.visible = params.get("haze_enabled", false)

## 终止当前过渡Tween
func _kill_tween() -> void:
	if _transition_tween and _transition_tween.is_valid():
		_transition_tween.kill()

## 字符串转预设枚举
func _preset_from_string(preset_name: String) -> Preset:
	match preset_name.to_lower():
		"city":
			return Preset.CITY
		"wasteland":
			return Preset.WASTELAND
		"dungeon":
			return Preset.DUNGEON
		"battle":
			return Preset.BATTLE
		"title":
			return Preset.TITLE
	push_warning("[Hd2dManager] 未知预设名称: %s, 使用默认CITY" % preset_name)
	return Preset.CITY

## ===== 战斗过渡效果 =====

## 播放战斗开始过渡效果
## duration 过渡时长
func play_battle_start_transition(duration: float = 0.6) -> void:
	if not enabled or not _battle_transition_rect:
		return
	_battle_transition_rect.visible = true
	var mat: ShaderMaterial = _battle_transition_rect.material as ShaderMaterial
	mat.set_shader_parameter("transition_type", 0)  # 战斗开始
	mat.set_shader_parameter("flash_intensity", 1.8)
	mat.set_shader_parameter("flash_color", Color(1.0, 1.0, 1.0, 1.0))
	
	# 动画进度
	var tween := create_tween()
	tween.tween_method(
		func(val: float) -> void: mat.set_shader_parameter("progress", val),
		0.0, 1.0, duration
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func(): _battle_transition_rect.visible = false)

## 播放战斗结束过渡效果
## duration 过渡时长
func play_battle_end_transition(duration: float = 0.5) -> void:
	if not enabled or not _battle_transition_rect:
		return
	_battle_transition_rect.visible = true
	var mat: ShaderMaterial = _battle_transition_rect.material as ShaderMaterial
	mat.set_shader_parameter("transition_type", 1)  # 战斗结束
	mat.set_shader_parameter("flash_intensity", 1.2)
	mat.set_shader_parameter("flash_color", Color(1.0, 0.95, 0.9, 1.0))
	
	var tween := create_tween()
	tween.tween_method(
		func(val: float) -> void: mat.set_shader_parameter("progress", val),
		0.0, 1.0, duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func(): _battle_transition_rect.visible = false)

## 播放战斗胜利过渡效果
## duration 过渡时长
func play_battle_victory_transition(duration: float = 0.8) -> void:
	if not enabled or not _battle_transition_rect:
		return
	_battle_transition_rect.visible = true
	var mat: ShaderMaterial = _battle_transition_rect.material as ShaderMaterial
	mat.set_shader_parameter("transition_type", 2)  # 战斗胜利
	mat.set_shader_parameter("flash_intensity", 1.5)
	mat.set_shader_parameter("flash_color", Color(1.0, 0.95, 0.6, 1.0))  # 金色
	
	var tween := create_tween()
	tween.tween_method(
		func(val: float) -> void: mat.set_shader_parameter("progress", val),
		0.0, 1.0, duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func(): _battle_transition_rect.visible = false)

## ===== HD-2D Master 着色器控制 =====

## 设置Master着色器参数（高级API）
func set_hd2d_master_params(
	blur_str: float = 2.5,
	vignette_int: float = 0.6,
	sat_boost: float = 1.08,
	temp: float = 0.12
) -> void:
	if not enabled or not _master_rect:
		return
	_master_rect.visible = true
	var mat: ShaderMaterial = _master_rect.material as ShaderMaterial
	mat.set_shader_parameter("blur_strength", blur_str)
	mat.set_shader_parameter("vignette_intensity", vignette_int)
	mat.set_shader_parameter("saturation_boost", sat_boost)
	mat.set_shader_parameter("color_temperature", temp)

## 设置色调映射参数
func set_tone_mapping(exposure: float = 1.1, gamma: float = 1.05) -> void:
	if not enabled or not _master_rect:
		return
	var mat: ShaderMaterial = _master_rect.material as ShaderMaterial
	mat.set_shader_parameter("exposure", exposure)
	mat.set_shader_parameter("gamma", gamma)
