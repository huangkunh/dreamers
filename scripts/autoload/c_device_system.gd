extends Node
## C装置战斗系统 (CDeviceBattleSystem)
## 处理Metal Max标志性的C装置技能在战斗中的效果
## 作为BattleEffects的扩展运行

## C装置技能效果处理

## 处理迎击技能 (拦截敌方攻击)
## 返回true如果攻击被拦截
static func try_intercept(tank_data: Dictionary, attacker_attack: int) -> bool:
	var c_device = tank_data.get("c_device", {})
	if c_device.is_empty():
		return false
	if c_device.get("skill", -1) != 0:  # CSkillType.INTERCEPT
		return false

	# 迎击成功率 = 30% + 速度差*2%
	var intercept_chance = 0.3
	var speed_diff = tank_data.get("speed", 0) - attacker_attack * 0.1
	intercept_chance += speed_diff * 0.002
	intercept_chance = clamp(intercept_chance, 0.1, 0.8)

	var intercepted = randf() <= intercept_chance
	if intercepted:
		print("[CDevice] 迎击成功! 拦截率: %.0f%%" % (intercept_chance * 100))
	return intercepted

## 处理援护技能 (为队友挡攻击)
## 返回true如果援护触发
static func try_support(tank_data: Dictionary, target_hp: int, target_max_hp: int) -> bool:
	var c_device = tank_data.get("c_device", {})
	if c_device.is_empty():
		return false
	if c_device.get("skill", -1) != 1:  # CSkillType.SUPPORT
		return false

	# 当队友HP低于50%时有概率援护
	if target_hp > target_max_hp * 0.5:
		return false

	var support_chance = 0.4  # 40%援护率
	var triggered = randf() <= support_chance
	if triggered:
		print("[CDevice] 援护触发! 为队友挡下攻击")
	return triggered

## 处理自动归返技能 (HP低时自动撤退)
## 返回true如果触发自动归返
static func check_auto_return(tank_data: Dictionary) -> bool:
	var c_device = tank_data.get("c_device", {})
	if c_device.is_empty():
		return false
	if c_device.get("skill", -1) != 2:  # CSkillType.AUTO_RETURN
		return false

	var hp = tank_data.get("current_hp", 0)
	var max_hp = tank_data.get("max_hp", 1)

	# HP低于20%时触发
	if hp <= max_hp * 0.2:
		print("[CDevice] 自动归返触发! HP: %d/%d" % [hp, max_hp])
		return true
	return false

## 处理目标锁定技能 (提高命中率)
## 返回命中率修正
static func get_target_lock_bonus(tank_data: Dictionary) -> float:
	var c_device = tank_data.get("c_device", {})
	if c_device.is_empty():
		return 0.0
	if c_device.get("skill", -1) != 3:  # CSkillType.TARGET_LOCK
		return 0.0

	# 目标锁定提供20%命中率加成
	return 0.2

## 获取C装置技能名称
static func get_skill_name(skill_type: int) -> String:
	match skill_type:
		0: return "迎击"
		1: return "援护"
		2: return "自动归返"
		3: return "目标锁定"
		_: return "无"

## 获取C装置技能描述
static func get_skill_description(skill_type: int) -> String:
	match skill_type:
		0: return "有概率拦截敌方攻击，使其无效"
		1: return "队友HP低于50%时有概率为其挡下攻击"
		2: return "HP低于20%时自动撤退到安全区域"
		3: return "提高20%命中率"
		_: return "无技能"
