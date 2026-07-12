extends Node
## 敌人AI系统 (EnemyAI)
## 为敌人提供智能行为决策
## 根据敌人状态、玩家状态、战斗局势选择最优行动

## AI行为类型
enum BehaviorType {
	RANDOM,      ## 随机选择技能
	AGGRESSIVE,  ## 优先攻击HP最低的目标
	DEFENSIVE,   ## HP低时优先防御/治疗
	SMART,       ## 综合策略 (根据局势调整)
	BOSS,        ## BOSS专用AI (多阶段)
}

## 决策上下文
class DecisionContext:
	var enemy_unit: Dictionary       ## 敌人单位数据
	var enemy_scene: Node            ## 敌人场景节点
	var player_units: Array          ## 所有玩家单位
	var player_scenes: Array         ## 所有玩家场景
	var turn_count: int = 0         ## 当前回合数
	var enemy_hp_percent: float = 1.0  ## 敌人HP百分比

## 选择敌人行动
## context: 决策上下文
## 返回: {skill, target_index}
static func choose_action(context: DecisionContext) -> Dictionary:
	var unit = context.enemy_unit
	var behavior = unit.get("ai_behavior", BehaviorType.RANDOM)
	var skills = unit.get("skills", [])

	if skills.is_empty():
		return {"skill": null, "target_index": 0}

	match behavior:
		BehaviorType.AGGRESSIVE:
			return _aggressive_ai(context, skills)
		BehaviorType.DEFENSIVE:
			return _defensive_ai(context, skills)
		BehaviorType.SMART:
			return _smart_ai(context, skills)
		BehaviorType.BOSS:
			return _boss_ai(context, skills)
		_:
			return _random_ai(context, skills)

## 随机AI
static func _random_ai(context: DecisionContext, skills: Array) -> Dictionary:
	var skill_index = randi() % skills.size()
	var target_index = _get_random_target(context)
	return {"skill": skills[skill_index], "target_index": target_index}

## 激进AI - 优先攻击HP最低的目标
static func _aggressive_ai(context: DecisionContext, skills: Array) -> Dictionary:
	# 优先使用攻击技能
	var attack_skills = skills.filter(func(s): return s.get("skill_strength", 0) > 0)
	var skill = attack_skills.pick_random() if not attack_skills.is_empty() else skills[0]

	# 选择HP最低的玩家
	var target_index = _get_lowest_hp_target(context)
	return {"skill": skill, "target_index": target_index}

## 防御AI - HP低时优先治疗/防御
static func _defensive_ai(context: DecisionContext, skills: Array) -> Dictionary:
	# HP低于30%时优先治疗
	if context.enemy_hp_percent < 0.3:
		var heal_skills = skills.filter(func(s): return s.get("skill_strength", 0) < 0)
		if not heal_skills.is_empty():
			return {"skill": heal_skills[0], "target_index": -1}  # -1表示自己

	# 否则正常攻击
	var attack_skills = skills.filter(func(s): return s.get("skill_strength", 0) > 0)
	var skill = attack_skills.pick_random() if not attack_skills.is_empty() else skills[0]
	return {"skill": skill, "target_index": _get_random_target(context)}

## 智能AI - 综合策略
static func _smart_ai(context: DecisionContext, skills: Array) -> Dictionary:
	# HP低于20%时优先治疗
	if context.enemy_hp_percent < 0.2:
		var heal_skills = skills.filter(func(s): return s.get("skill_strength", 0) < 0)
		if not heal_skills.is_empty():
			return {"skill": heal_skills[0], "target_index": -1}

	# 第3回合后优先使用强力技能
	if context.turn_count >= 3:
		var strong_skills = skills.filter(func(s): return s.get("skill_strength", 0) >= 1.0)
		if not strong_skills.is_empty() and randf() < 0.6:
			return {"skill": strong_skills.pick_random(), "target_index": _get_lowest_hp_target(context)}

	# 默认: 70%攻击最低HP, 30%随机
	if randf() < 0.7:
		var attack_skills = skills.filter(func(s): return s.get("skill_strength", 0) > 0)
		var skill = attack_skills.pick_random() if not attack_skills.is_empty() else skills[0]
		return {"skill": skill, "target_index": _get_lowest_hp_target(context)}
	else:
		return _random_ai(context, skills)

## BOSS AI - 多阶段策略
static func _boss_ai(context: DecisionContext, skills: Array) -> Dictionary:
	# 阶段1: HP > 50% - 普通攻击为主
	if context.enemy_hp_percent > 0.5:
		var normal_skills = skills.filter(func(s): return s.get("skill_strength", 0) <= 1.0)
		var skill = normal_skills.pick_random() if not normal_skills.is_empty() else skills[0]
		return {"skill": skill, "target_index": _get_random_target(context)}

	# 阶段2: HP 20%-50% - 使用更强技能
	elif context.enemy_hp_percent > 0.2:
		var strong_skills = skills.filter(func(s): return s.get("skill_strength", 0) > 0.8)
		var skill = strong_skills.pick_random() if not strong_skills.is_empty() else skills[0]
		return {"skill": skill, "target_index": _get_lowest_hp_target(context)}

	# 阶段3: HP < 20% - 拼命攻击 + 治疗
	else:
		if randf() < 0.3:
			# 30%概率治疗
			var heal_skills = skills.filter(func(s): return s.get("skill_strength", 0) < 0)
			if not heal_skills.is_empty():
				return {"skill": heal_skills[0], "target_index": -1}
		# 70%概率强力攻击
		var strongest = skills.filter(func(s): return s.get("skill_strength", 0) > 0)
		if not strongest.is_empty():
			# 选择最强技能
			strongest.sort_custom(func(a, b): return a.get("skill_strength", 0) > b.get("skill_strength", 0))
			return {"skill": strongest[0], "target_index": _get_lowest_hp_target(context)}
		return _random_ai(context, skills)

## 获取HP最低的玩家目标索引
static func _get_lowest_hp_target(context: DecisionContext) -> int:
	var lowest_hp = 999999
	var lowest_index = 0
	for i in range(context.player_units.size()):
		var unit = context.player_units[i]
		var hp = unit.get("current_health", unit.get("current_hp", 100))
		if hp > 0 and hp < lowest_hp:
			lowest_hp = hp
			lowest_index = i
	return lowest_index

## 获取随机存活目标
static func _get_random_target(context: DecisionContext) -> int:
	var alive_indices = []
	for i in range(context.player_units.size()):
		var unit = context.player_units[i]
		var hp = unit.get("current_health", unit.get("current_hp", 100))
		if hp > 0:
			alive_indices.append(i)
	if alive_indices.is_empty():
		return 0
	return alive_indices.pick_random()

## 为敌人设置AI行为类型
static func get_behavior_name(behavior: int) -> String:
	match behavior:
		BehaviorType.RANDOM: return "随机"
		BehaviorType.AGGRESSIVE: return "激进"
		BehaviorType.DEFENSIVE: return "防御"
		BehaviorType.SMART: return "智能"
		BehaviorType.BOSS: return "BOSS"
		_: return "未知"
