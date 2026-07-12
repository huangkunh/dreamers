extends Node
## 战斗数值平衡系统 (BattleBalance)
## 调整战斗中的伤害/经验/金币等数值
## 确保游戏难度曲线合理

## 难度等级
enum Difficulty {
	EASY,      ## 简单 (伤害x0.7, 经验x1.3)
	NORMAL,    ## 普通 (默认)
	HARD,      ## 困难 (伤害x1.3, 经验x0.9)
	VERY_HARD, ## 极难 (伤害x1.6, 经验x0.7)
}

## 当前难度
var current_difficulty: int = Difficulty.NORMAL

## 难度配置
const DIFFICULTY_CONFIG := {
	Difficulty.EASY: {
		"player_damage_mult": 1.3,      ## 玩家伤害倍率
		"enemy_damage_mult": 0.7,       ## 敌人伤害倍率
		"exp_mult": 1.3,                ## 经验倍率
		"coins_mult": 1.2,              ## 金币倍率
		"encounter_rate_mult": 0.8,     ## 遇敌率倍率
		"name": "简单",
	},
	Difficulty.NORMAL: {
		"player_damage_mult": 1.0,
		"enemy_damage_mult": 1.0,
		"exp_mult": 1.0,
		"coins_mult": 1.0,
		"encounter_rate_mult": 1.0,
		"name": "普通",
	},
	Difficulty.HARD: {
		"player_damage_mult": 0.9,
		"enemy_damage_mult": 1.3,
		"exp_mult": 0.9,
		"coins_mult": 0.9,
		"encounter_rate_mult": 1.2,
		"name": "困难",
	},
	Difficulty.VERY_HARD: {
		"player_damage_mult": 0.8,
		"enemy_damage_mult": 1.6,
		"exp_mult": 0.7,
		"coins_mult": 0.7,
		"encounter_rate_mult": 1.5,
		"name": "极难",
	},
}

## 获取当前难度配置
func get_config() -> Dictionary:
	return DIFFICULTY_CONFIG.get(current_difficulty, DIFFICULTY_CONFIG[Difficulty.NORMAL])

## 获取难度名称
func get_difficulty_name() -> String:
	return get_config().get("name", "普通")

## 设置难度
func set_difficulty(diff: int) -> void:
	current_difficulty = diff
	print("[BattleBalance] 难度设置为: " + get_difficulty_name())

## 计算玩家伤害
## base_damage: 基础伤害
func calc_player_damage(base_damage: int) -> int:
	var mult = get_config().get("player_damage_mult", 1.0)
	return int(base_damage * mult)

## 计算敌人伤害
## base_damage: 基础伤害
func calc_enemy_damage(base_damage: int) -> int:
	var mult = get_config().get("enemy_damage_mult", 1.0)
	return int(base_damage * mult)

## 计算获得经验
## base_exp: 基础经验
func calc_exp(base_exp: int) -> int:
	var mult = get_config().get("exp_mult", 1.0)
	return int(base_exp * mult)

## 计算获得金币
## base_coins: 基础金币
func calc_coins(base_coins: int) -> int:
	var mult = get_config().get("coins_mult", 1.0)
	return int(base_coins * mult)

## 获取遇敌率倍率
func get_encounter_rate_mult() -> float:
	return get_config().get("encounter_rate_mult", 1.0)

## 获取所有难度选项 (用于UI)
func get_all_difficulties() -> Array:
	var result = []
	for diff in [Difficulty.EASY, Difficulty.NORMAL, Difficulty.HARD, Difficulty.VERY_HARD]:
		result.append({
			"id": diff,
			"name": DIFFICULTY_CONFIG[diff].name,
		})
	return result
