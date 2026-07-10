extends Node
## 游戏时间系统 (GameTimeSystem)
## 管理游戏内的昼夜循环
## 影响环境光照和遇敌率

## 时间阶段
enum TimePhase {
	DAWN,     ## 黎明 (5:00-8:00)
	DAY,      ## 白天 (8:00-17:00)
	DUSK,     ## 黄昏 (17:00-20:00)
	NIGHT,    ## 夜晚 (20:00-5:00)
}

## 当前游戏时间 (小时, 0-24)
var current_hour: float = 8.0
## 时间流速 (游戏小时/真实秒)
var time_scale: float = 0.05  ## 20秒=1游戏小时
## 当前阶段
var current_phase: int = TimePhase.DAY
## 是否启用昼夜循环
var enabled: bool = true

## 信号
signal phase_changed(new_phase: int)
signal hour_changed(hour: float)

## 阶段配置
const PHASE_CONFIG := {
	TimePhase.DAWN: {
		"ambient_color": Color(0.8, 0.6, 0.4, 1),
		"ambient_energy": 0.6,
		"sky_color": Color(0.9, 0.7, 0.5),
		"encounter_modifier": 1.0,
		"name": "黎明",
	},
	TimePhase.DAY: {
		"ambient_color": Color(1, 1, 0.9, 1),
		"ambient_energy": 1.0,
		"sky_color": Color(0.5, 0.7, 1),
		"encounter_modifier": 0.8,
		"name": "白天",
	},
	TimePhase.DUSK: {
		"ambient_color": Color(0.9, 0.6, 0.4, 1),
		"ambient_energy": 0.7,
		"sky_color": Color(0.8, 0.4, 0.3),
		"encounter_modifier": 1.2,
		"name": "黄昏",
	},
	TimePhase.NIGHT: {
		"ambient_color": Color(0.3, 0.3, 0.5, 1),
		"ambient_energy": 0.4,
		"sky_color": Color(0.1, 0.1, 0.2),
		"encounter_modifier": 1.5,
		"name": "夜晚",
	},
}

func _ready() -> void:
	_update_phase()

func _process(delta: float) -> void:
	if not enabled:
		return

	# 推进时间
	current_hour += time_scale * delta
	if current_hour >= 24.0:
		current_hour -= 24.0

	# 检查阶段变化
	var old_phase = current_phase
	_update_phase()
	if old_phase != current_phase:
		phase_changed.emit(current_phase)
		print("[GameTime] 进入" + get_phase_name() + "时段")

	hour_changed.emit(current_hour)

## 更新当前阶段
func _update_phase() -> void:
	if current_hour >= 5.0 and current_hour < 8.0:
		current_phase = TimePhase.DAWN
	elif current_hour >= 8.0 and current_hour < 17.0:
		current_phase = TimePhase.DAY
	elif current_hour >= 17.0 and current_hour < 20.0:
		current_phase = TimePhase.DUSK
	else:
		current_phase = TimePhase.NIGHT

## 获取当前阶段名称
func get_phase_name() -> String:
	var config = PHASE_CONFIG.get(current_phase, {})
	return config.get("name", "未知")

## 获取当前环境光颜色
func get_ambient_color() -> Color:
	var config = PHASE_CONFIG.get(current_phase, {})
	return config.get("ambient_color", Color.WHITE)

## 获取当前环境光强度
func get_ambient_energy() -> float:
	var config = PHASE_CONFIG.get(current_phase, {})
	return config.get("ambient_energy", 1.0)

## 获取遇敌率修正
func get_encounter_modifier() -> float:
	var config = PHASE_CONFIG.get(current_phase, {})
	return config.get("encounter_modifier", 1.0)

## 获取格式化时间字符串
func get_time_string() -> String:
	var hours = int(current_hour)
	var minutes = int((current_hour - hours) * 60)
	return "%02d:%02d" % [hours, minutes]

## 设置时间
func set_time(hour: float) -> void:
	current_hour = clamp(hour, 0.0, 23.999)
	_update_phase()
	hour_changed.emit(current_hour)
	phase_changed.emit(current_phase)

## 快进时间 (用于测试)
func skip_time(hours: float) -> void:
	set_time(current_hour + hours)
