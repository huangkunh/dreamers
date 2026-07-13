extends Node
## 战车战系统 (TankBattleSystem)
## Metal Max原作核心: 战车战与白刃战的双模式战斗
## 战车战: 使用主炮/副炮/C装置，消耗弹药
## 白刃战: 玩家下车近战，不消耗弹药但防御低

## 战斗模式
enum BattleMode {
	ON_FOOT,     ## 白刃战 (下车)
	IN_TANK,     ## 战车战 (上车)
}

## 当前战斗模式
var current_mode: int = BattleMode.ON_FOOT

## 信号
signal mode_changed(new_mode: int)
signal ammo_changed(current: int, max: int)
signal fuel_changed(current: int, max: int)

## 切换战斗模式 (乘降)
func toggle_battle_mode() -> void:
	if current_mode == BattleMode.ON_FOOT:
		# 检查是否有战车
		var tank = TankSystem.get_active_tank()
		if tank and tank.current_hp > 0:
			current_mode = BattleMode.IN_TANK
			print("[TankBattle] 切换到战车战模式")
		else:
			print("[TankBattle] 没有可用战车")
			return
	else:
		current_mode = BattleMode.ON_FOOT
		print("[TankBattle] 切换到白刃战模式")

	mode_changed.emit(current_mode)

## 获取当前模式名称
func get_mode_name() -> String:
	match current_mode:
		BattleMode.ON_FOOT: return "白刃战"
		BattleMode.IN_TANK: return "战车战"
		_: return "未知"

## 获取当前模式的伤害倍率
func get_damage_multiplier() -> float:
	match current_mode:
		BattleMode.ON_FOOT: return 1.0  ## 白刃战正常伤害
		BattleMode.IN_TANK: return 1.5  ## 战车战伤害更高
		_: return 1.0

## 获取当前模式的防御倍率
func get_defense_multiplier() -> float:
	match current_mode:
		BattleMode.ON_FOOT: return 1.0  ## 白刃战正常防御
		BattleMode.IN_TANK: return 2.0  ## 战车战防御更高
		_: return 1.0

## 战车主炮攻击
## tank: 战车数据
## 返回: 伤害值
func tank_main_cannon_attack(tank) -> int:
	if current_mode != BattleMode.IN_TANK:
		return 0

	# 检查弹药
	if tank.current_ammo <= 0:
		print("[TankBattle] 弹药耗尽!")
		return 0

	# 消耗弹药
	tank.current_ammo -= 1
	ammo_changed.emit(tank.current_ammo, tank.max_ammo)

	# 计算伤害 = 主炮攻击力 * 难度倍率
	var base_damage = tank.attack
	var damage = BattleBalance.calc_player_damage(base_damage)
	print("[TankBattle] 主炮射击! 伤害: %d, 剩余弹药: %d" % [damage, tank.current_ammo])
	return damage

## 战车副炮攻击 (机枪扫射)
## tank: 战车数据
## target_count: 目标数量
## 返回: 每个目标的伤害
func tank_sub_weapon_attack(tank, target_count: int) -> int:
	if current_mode != BattleMode.IN_TANK:
		return 0

	# 副炮不消耗弹药，但伤害较低
	var base_damage = int(tank.attack * 0.4)
	var damage = BattleBalance.calc_player_damage(base_damage)
	print("[TankBattle] 机枪扫射! 每体伤害: %d, 目标数: %d" % [damage, target_count])
	return damage

## 战车移动消耗燃料
## tank: 战车数据
## distance: 移动距离
func consume_fuel(tank, distance: float) -> void:
	if current_mode != BattleMode.IN_TANK:
		return

	var fuel_cost = int(distance * 0.5)
	tank.current_fuel = max(0, tank.current_fuel - fuel_cost)
	fuel_changed.emit(tank.current_fuel, tank.max_fuel)

	if tank.current_fuel <= 0:
		print("[TankBattle] 燃料耗尽! 强制下车")
		current_mode = BattleMode.ON_FOOT
		mode_changed.emit(current_mode)

## 检查是否可以切换到战车模式
func can_enter_tank() -> bool:
	var tank = TankSystem.get_active_tank()
	if not tank:
		return false
	if tank.current_hp <= 0:
		return false
	if tank.current_fuel <= 0:
		return false
	return true

## 获取战车状态摘要
func get_tank_status_summary() -> String:
	var tank = TankSystem.get_active_tank()
	if not tank:
		return "无战车"

	var status = "%s | HP:%d/%d | 弹药:%d/%d | 燃料:%d/%d" % [
		tank.name,
		tank.current_hp, tank.max_hp,
		tank.current_ammo, tank.max_ammo,
		tank.current_fuel, tank.max_fuel
	]
	return status
