extends Node
## 状态效果系统 (StatusEffectSystem)
## 管理战斗中单位的状态效果 (中毒/麻痹/眩晕/增益/减益等)
## 作为 Autoload 单例运行

## 状态效果实例
class StatusInstance:
	var effect_type: int    ## 效果类型 (SkillData.StatusEffect)
	var duration: int       ## 剩余回合
	var power: float = 1.0  ## 效果强度
	var source_id: String = ""  ## 施加者ID

## 应用状态效果到单位
## unit: 战斗单位字典
## effect_type: SkillData.StatusEffect枚举值
## duration: 持续回合数
## power: 效果强度
func apply_status(unit: Dictionary, effect_type: int, duration: int, power: float = 1.0, source_id: String = "") -> void:
	if not unit.has("status_effects"):
		unit["status_effects"] = []

	# 检查是否已有同类效果
	for existing in unit["status_effects"]:
		if existing.effect_type == effect_type:
			# 刷新持续时间和强度
			existing.duration = max(existing.duration, duration)
			existing.power = max(existing.power, power)
			print("[Status] 刷新状态: %s (持续%d回合)" % [get_status_name(effect_type), duration])
			return

	# 添加新效果
	var status := StatusInstance.new()
	status.effect_type = effect_type
	status.duration = duration
	status.power = power
	status.source_id = source_id
	unit["status_effects"].append(status)
	print("[Status] 施加状态: %s (持续%d回合)" % [get_status_name(effect_type), duration])

## 回合结束处理 - 更新所有状态
func process_turn_end(unit: Dictionary) -> void:
	if not unit.has("status_effects"):
		return

	var expired := []
	for i in range(unit["status_effects"].size()):
		var status = unit["status_effects"][i]
		# 处理持续伤害
		match status.effect_type:
			0:  # POISON
				var damage = int(unit.get("max_health", 100) * 0.05 * status.power)
				unit["current_health"] = max(0, unit["current_health"] - damage)
				print("[Status] 中毒伤害: %d" % damage)
			6:  # BLEED
				var damage = int(unit.get("max_health", 100) * 0.03 * status.power)
				unit["current_health"] = max(0, unit["current_health"] - damage)
				print("[Status] 流血伤害: %d" % damage)

		# 减少持续时间
		status.duration -= 1
		if status.duration <= 0:
			expired.append(i)

	# 移除过期效果 (倒序删除)
	expired.reverse()
	for i in expired:
		var status = unit["status_effects"][i]
		print("[Status] 状态结束: %s" % get_status_name(status.effect_type))
		unit["status_effects"].remove_at(i)

## 检查单位是否可以行动 (麻痹/眩晕检查)
## 返回true如果可以行动
func can_act(unit: Dictionary) -> bool:
	if not unit.has("status_effects"):
		return true
	for status in unit["status_effects"]:
		match status.effect_type:
			1:  # PARALYZE
				if randf() < 0.5 * status.power:  # 50%概率无法行动
					print("[Status] 麻痹发作，无法行动")
					return false
			2:  # STUN
				print("[Status] 眩晕，无法行动")
				return false
	return true

## 获取攻击力修正 (增益/减益)
func get_attack_modifier(unit: Dictionary) -> float:
	if not unit.has("status_effects"):
		return 1.0
	var modifier := 1.0
	for status in unit["status_effects"]:
		match status.effect_type:
			4:  # ATTACK_UP
				modifier += 0.3 * status.power
	return modifier

## 获取防御力修正
func get_defense_modifier(unit: Dictionary) -> float:
	if not unit.has("status_effects"):
		return 1.0
	var modifier := 1.0
	for status in unit["status_effects"]:
		match status.effect_type:
			3:  # DEFENSE_UP
				modifier += 0.3 * status.power
	return modifier

## 获取速度修正
func get_speed_modifier(unit: Dictionary) -> float:
	if not unit.has("status_effects"):
		return 1.0
	var modifier := 1.0
	for status in unit["status_effects"]:
		match status.effect_type:
			5:  # SPEED_UP
				modifier += 0.2 * status.power
	return modifier

## 获取状态名称
func get_status_name(effect_type: int) -> String:
	match effect_type:
		0: return "中毒"
		1: return "麻痹"
		2: return "眩晕"
		3: return "防御提升"
		4: return "攻击提升"
		5: return "速度提升"
		6: return "流血"
		_: return "未知"

## 获取状态颜色 (用于UI显示)
func get_status_color(effect_type: int) -> Color:
	match effect_type:
		0: return Color(0.5, 0.8, 0.3)    # 中毒-绿
		1: return Color(0.8, 0.8, 0.3)    # 麻痹-黄
		2: return Color(0.9, 0.9, 0.5)    # 眩晕-浅黄
		3: return Color(0.3, 0.5, 0.9)    # 防御提升-蓝
		4: return Color(0.9, 0.4, 0.3)    # 攻击提升-红
		5: return Color(0.3, 0.9, 0.9)    # 速度提升-青
		6: return Color(0.8, 0.2, 0.2)    # 流血-深红
		_: return Color.WHITE

## 清除单位所有状态
func clear_all_statuses(unit: Dictionary) -> void:
	unit["status_effects"] = []
