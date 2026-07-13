extends Node
## 荒野天气系统 (WastelandWeather)
## 动态控制荒野场景的天气效果
## HD-2D风格：平滑过渡的天气变化、视觉提示

## 天气类型枚举
enum WeatherType {
	CLEAR,      # 晴朗 - 标准沙漠炎热天气
	HAZY,       # 雾霾 - 热浪扭曲增强
	SANDSTORM,  # 沙尘暴 - 粒子增强、视野降低
	STORMY,     # 风暴 - 强风效果
	OVERCAST    # 多云 - 降低光照强度
}

## 当前天气类型
@export var current_weather: WeatherType = WeatherType.CLEAR
## 天气变化周期 (秒)
@export var weather_cycle_duration: float = 300.0  # 5分钟一个周期
## 天气变化最小间隔
@export var min_weather_change_interval: float = 60.0
## 随机天气变化概率
@export var random_change_probability: float = 0.02

## 世界环境节点
var _world_env: WorldEnvironment = null
## 热浪叠加层
var _heat_haze_overlay: ColorRect = null
## 沙尘粒子
var _sand_particles: GPUParticles3D = null
## 方向光
var _directional_light: DirectionalLight3D = null
## 沙尘暴区域列表
var _sandstorm_zones: Array = []
## 计时器
var _timer: float = 0.0
## 下次天气变化时间
var _next_change_time: float = 0.0
## 天气过渡持续时间
var _transition_duration: float = 5.0
## 当前过渡进度
var _transition_progress: float = 1.0
## 目标天气
var _target_weather: WeatherType = WeatherType.CLEAR
## 原始环境参数
var _original_env_params: Dictionary = {}

func _ready() -> void:
	# 获取场景节点
	_find_scene_nodes()
	
	# 保存原始环境参数
	if _world_env and _world_env.environment:
		_save_original_params()
	
	# 设置初始天气
	_apply_weather_immediate(current_weather)
	
	# 初始化下次变化时间
	_next_change_time = weather_cycle_duration

func _find_scene_nodes() -> void:
	var parent = get_parent()
	if not parent:
		return
	
	# 查找关键节点
	_world_env = parent.find_child("WorldEnvironment", true, false)
	_heat_haze_overlay = parent.find_child("HeatHazeOverlay", true, false)
	_sand_particles = parent.find_child("SandParticles", true, false)
	_directional_light = parent.find_child("DirectionalLight3D", true, false)
	
	# 查找所有沙尘暴区域
	for child in parent.get_children():
		if child.get_script() and child.get_script().resource_path.find("sandstorm_zone") != -1:
			_sandstorm_zones.append(child)

func _save_original_params() -> void:
	var env = _world_env.environment
	_original_env_params = {
		"ambient_light_energy": env.ambient_light_energy,
		"fog_density": env.fog_density,
		"volumetric_fog_density": env.volumetric_fog_density,
		"glow_intensity": env.glow_intensity
	}

func _process(delta: float) -> void:
	_timer += delta
	
	# 检查是否需要天气变化
	if _timer >= _next_change_time:
		_check_weather_change()
	
	# 处理天气过渡
	if _transition_progress < 1.0:
		_transition_progress += delta / _transition_duration
		_transition_progress = clamp(_transition_progress, 0.0, 1.0)
		_apply_weather_transition()

func _check_weather_change() -> void:
	_timer = 0.0
	_next_change_time = weather_cycle_duration
	
	# 随机天气变化
	if randf() < random_change_probability:
		_trigger_weather_change()

func _trigger_weather_change() -> void:
	# 随机选择新天气
	var new_weather = _get_random_weather()
	
	# 避免选择相同天气
	while new_weather == current_weather:
		new_weather = _get_random_weather()
	
	_target_weather = new_weather
	_transition_progress = 0.0
	
	print("[WastelandWeather] 天气变化: %s -> %s" % [WeatherType.keys()[current_weather], WeatherType.keys()[_target_weather]])

func _get_random_weather() -> WeatherType:
	var weights = {
		WeatherType.CLEAR: 50,
		WeatherType.HAZY: 25,
		WeatherType.SANDSTORM: 10,
		WeatherType.STORMY: 10,
		WeatherType.OVERCAST: 5
	}
	
	var total_weight = 0
	for weight in weights.values():
		total_weight += weight
	
	var random_val = randi() % total_weight
	var accumulated = 0
	
	for weather_type in weights.keys():
		accumulated += weights[weather_type]
		if random_val < accumulated:
			return weather_type
	
	return WeatherType.CLEAR

func _apply_weather_transition() -> void:
	if not _world_env or not _world_env.environment:
		return
	
	var env = _world_env.environment
	
	# 计算过渡参数
	var from_params = _get_weather_params(current_weather)
	var to_params = _get_weather_params(_target_weather)
	
	# 平滑过渡
	env.ambient_light_energy = lerp(from_params.ambient_light_energy, to_params.ambient_light_energy, _transition_progress)
	env.fog_density = lerp(from_params.fog_density, to_params.fog_density, _transition_progress)
	env.volumetric_fog_density = lerp(from_params.volumetric_fog_density, to_params.volumetric_fog_density, _transition_progress)
	env.glow_intensity = lerp(from_params.glow_intensity, to_params.glow_intensity, _transition_progress)
	
	# 热浪效果过渡
	if _heat_haze_overlay and _heat_haze_overlay.material:
		var haze_strength = lerp(from_params.haze_strength, to_params.haze_strength, _transition_progress)
		var mat = _heat_haze_overlay.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("distortion_strength", haze_strength)
	
	# 沙尘粒子过渡
	if _sand_particles:
		var particle_amount = lerp(from_params.particle_amount, to_params.particle_amount, _transition_progress)
		_sand_particles.emitting = particle_amount > 0
		_sand_particles.amount = int(particle_amount)
	
	# 光照强度过渡
	if _directional_light:
		var light_energy = lerp(from_params.light_energy, to_params.light_energy, _transition_progress)
		_directional_light.light_energy = light_energy
	
	# 完成过渡
	if _transition_progress >= 1.0:
		current_weather = _target_weather
		_update_sandstorm_zones()

func _update_sandstorm_zones() -> void:
	# 根据天气类型激活/取消激活沙尘暴区域
	for zone in _sandstorm_zones:
		if zone.has_method("activate_storm") and zone.has_method("_deactivate_storm"):
			if current_weather == WeatherType.SANDSTORM or current_weather == WeatherType.STORMY:
				zone.activate_storm()
			else:
				zone._deactivate_storm()

func _get_weather_params(weather: WeatherType) -> Dictionary:
	match weather:
		WeatherType.CLEAR:
			return {
				"ambient_light_energy": _original_env_params.get("ambient_light_energy", 0.6),
				"fog_density": _original_env_params.get("fog_density", 0.12),
				"volumetric_fog_density": _original_env_params.get("volumetric_fog_density", 0.04),
				"glow_intensity": _original_env_params.get("glow_intensity", 0.6),
				"haze_strength": 2.5,
				"particle_amount": 150,
				"light_energy": 1.5
			}
		WeatherType.HAZY:
			return {
				"ambient_light_energy": 0.5,
				"fog_density": 0.15,
				"volumetric_fog_density": 0.06,
				"glow_intensity": 0.5,
				"haze_strength": 5.0,
				"particle_amount": 200,
				"light_energy": 1.2
			}
		WeatherType.SANDSTORM:
			return {
				"ambient_light_energy": 0.35,
				"fog_density": 0.25,
				"volumetric_fog_density": 0.12,
				"glow_intensity": 0.3,
				"haze_strength": 4.0,
				"particle_amount": 400,
				"light_energy": 0.8
			}
		WeatherType.STORMY:
			return {
				"ambient_light_energy": 0.4,
				"fog_density": 0.18,
				"volumetric_fog_density": 0.08,
				"glow_intensity": 0.4,
				"haze_strength": 3.5,
				"particle_amount": 300,
				"light_energy": 1.0
			}
		WeatherType.OVERCAST:
			return {
				"ambient_light_energy": 0.45,
				"fog_density": 0.14,
				"volumetric_fog_density": 0.05,
				"glow_intensity": 0.35,
				"haze_strength": 1.5,
				"particle_amount": 100,
				"light_energy": 0.9
			}
	
	return _get_weather_params(WeatherType.CLEAR)

func _apply_weather_immediate(weather: WeatherType) -> void:
	current_weather = weather
	_target_weather = weather
	_transition_progress = 1.0
	
	if not _world_env or not _world_env.environment:
		return
	
	var params = _get_weather_params(weather)
	var env = _world_env.environment
	
	env.ambient_light_energy = params.ambient_light_energy
	env.fog_density = params.fog_density
	env.volumetric_fog_density = params.volumetric_fog_density
	env.glow_intensity = params.glow_intensity
	
	if _heat_haze_overlay and _heat_haze_overlay.material:
		var mat = _heat_haze_overlay.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("distortion_strength", params.haze_strength)
	
	if _sand_particles:
		_sand_particles.emitting = params.particle_amount > 0
		_sand_particles.amount = int(params.particle_amount)
	
	if _directional_light:
		_directional_light.light_energy = params.light_energy
	
	_update_sandstorm_zones()

## 手动设置天气 (用于测试或剧情事件)
func set_weather(weather: WeatherType, immediate: bool = false) -> void:
	if immediate:
		_apply_weather_immediate(weather)
	else:
		_target_weather = weather
		_transition_progress = 0.0

## 获取当前天气描述
func get_weather_description() -> String:
	match current_weather:
		WeatherType.CLEAR:
			return "晴朗炎热"
		WeatherType.HAZY:
			return "热浪雾霾"
		WeatherType.SANDSTORM:
			return "沙尘暴"
		WeatherType.STORMY:
			return "风暴"
		WeatherType.OVERCAST:
			return "多云"
	
	return "未知"