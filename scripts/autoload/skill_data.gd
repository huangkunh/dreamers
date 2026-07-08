extends Node
## 技能数据 (SkillData)
## 定义所有角色技能: 攻击、治疗、辅助等
## 作为 Autoload 单例运行

## 技能类型
enum SkillType {
	ATTACK,      ## 物理攻击
	RANGED,      ## 远程攻击
	HEAL,        ## 治疗
	BUFF,        ## 增益
	DEBUFF,      ## 减益
	TANK_ATTACK, ## 战车攻击
	TANK_REPAIR, ## 战车修理
}

## 目标类型
enum TargetType {
	ONE_ENEMY,   ## 单体敌人
	ALL_ENEMIES, ## 全体敌人
	ONE_ALLY,    ## 单体队友
	ALL_ALLIES,  ## 全体队友
	SELF,        ## 自己
}

## 状态效果
enum StatusEffect {
	NONE,
	POISON,      ## 中毒 (持续伤害)
	PARALYZE,    ## 麻痹 (无法行动)
	STUN,        ## 眩晕 (跳过回合)
	DEFENSE_UP,  ## 防御提升
	ATTACK_UP,   ## 攻击提升
	SPEED_UP,    ## 速度提升
	BLEED,       ## 流血 (持续伤害)
}

## 技能数据结构
class Skill:
	var id: String
	var name: String
	var description: String
	var skill_type: int
	var target_type: int
	var power: float = 1.0       ## 威力倍率
	var mp_cost: int = 0         ## MP消耗
	var hp_cost: int = 0         ## HP消耗 (自伤技能)
	var accuracy: float = 1.0    ## 命中率 (0-1)
	var status_effect: int = StatusEffect.NONE
	var status_chance: float = 0.0  ## 状态触发概率
	var status_duration: int = 0    ## 状态持续回合
	var animation: String = ""   ## 动画名称
	var icon_path: String = ""   ## 图标路径

## 所有技能
var skills: Dictionary = {}

func _ready() -> void:
	_init_skills()

## 初始化技能数据
func _init_skills() -> void:
	# ---- 玩家技能 ----
	_register_skill("normal_attack", "普通攻击", "基础物理攻击", SkillType.ATTACK, TargetType.ONE_ENEMY, 1.0, 0, 0, 0.95)
	_register_skill("slingshot", "弹弓射击", "远程攻击，不受防御影响", SkillType.RANGED, TargetType.ONE_ENEMY, 0.8, 0, 0, 0.9)
	_register_skill("power_strike", "强力一击", "威力1.5倍的强力攻击", SkillType.ATTACK, TargetType.ONE_ENEMY, 1.5, 5, 0, 0.85)
	_register_skill("double_strike", "连续攻击", "攻击两次，每次0.7倍威力", SkillType.ATTACK, TargetType.ONE_ENEMY, 0.7, 8, 0, 0.9)

	# ---- 治疗技能 ----
	_register_skill("first_aid", "急救", "恢复50HP", SkillType.HEAL, TargetType.SELF, 0.0, 0, 0, 1.0, "", 50)
	_register_skill("bandage", "包扎", "恢复30HP并止血", SkillType.HEAL, TargetType.ONE_ALLY, 0.0, 3, 0, 1.0, "", 30)

	# ---- 辅助技能 ----
	_register_skill("guard", "防御", "提升防御力，持续3回合", SkillType.BUFF, TargetType.SELF, 0.0, 2, 0, 1.0, "DEFENSE_UP", 0, 3)
	_register_skill("focus", "集中", "提升攻击力，持续3回合", SkillType.BUFF, TargetType.SELF, 0.0, 4, 0, 1.0, "ATTACK_UP", 0, 3)

	# ---- 减益技能 ----
	_register_skill("poison_dart", "毒针", "攻击并可能中毒", SkillType.ATTACK, TargetType.ONE_ENEMY, 0.6, 6, 0, 0.85, "POISON", 0.5, 3)
	_register_skill("flash_bang", "闪光弹", "可能眩晕敌人", SkillType.DEBUFF, TargetType.ONE_ENEMY, 0.0, 8, 0, 0.7, "STUN", 0.6, 1)

	# ---- 战车技能 ----
	_register_skill("tank_cannon", "主炮射击", "战车主炮攻击", SkillType.TANK_ATTACK, TargetType.ONE_ENEMY, 2.0, 0, 0, 0.9)
	_register_skill("tank_machine_gun", "机枪扫射", "战车机枪全体攻击", SkillType.TANK_ATTACK, TargetType.ALL_ENEMIES, 0.8, 0, 0, 0.8)
	_register_skill("tank_repair", "紧急修理", "恢复战车100HP", SkillType.TANK_REPAIR, TargetType.SELF, 0.0, 0, 0, 1.0, "", 100)

## 注册技能
func _register_skill(id: String, name: String, desc: String, type: int, target: int, power: float, mp: int, hp: int, acc: float, status: String = "", chance: float = 0.0, duration: int = 0, heal: int = 0) -> void:
	var skill := Skill.new()
	skill.id = id
	skill.name = name
	skill.description = desc
	skill.skill_type = type
	skill.target_type = target
	skill.power = power
	skill.mp_cost = mp
	skill.hp_cost = hp
	skill.accuracy = acc
	skill.animation = id

	# 状态效果映射
	match status:
		"POISON": skill.status_effect = StatusEffect.POISON
		"PARALYZE": skill.status_effect = StatusEffect.PARALYZE
		"STUN": skill.status_effect = StatusEffect.STUN
		"DEFENSE_UP": skill.status_effect = StatusEffect.DEFENSE_UP
		"ATTACK_UP": skill.status_effect = StatusEffect.ATTACK_UP
		"SPEED_UP": skill.status_effect = StatusEffect.SPEED_UP
		"BLEED": skill.status_effect = StatusEffect.BLEED
		_: skill.status_effect = StatusEffect.NONE

	skill.status_chance = chance
	skill.status_duration = duration

	# 治疗量存储在power中 (治疗技能)
	if type == SkillType.HEAL or type == SkillType.TANK_REPAIR:
		skill.power = float(heal)

	skills[id] = skill

## 获取技能
func get_skill(id: String) -> Skill:
	return skills.get(id, null)

## 获取技能ID列表
func get_skill_ids() -> Array:
	return skills.keys()

## 计算伤害
func calculate_damage(skill: Skill, attacker_attack: int, defender_defense: int) -> int:
	if skill.skill_type == SkillType.HEAL or skill.skill_type == SkillType.TANK_REPAIR:
		return int(skill.power)  # 治疗量

	# 基础伤害 = 攻击力 * 威力 - 防御力/2
	var base_damage := attacker_attack * skill.power - defender_defense * 0.5
	# 最低伤害1
	base_damage = max(1.0, base_damage)
	# 随机浮动 ±10%
	var variance := randf_range(0.9, 1.1)
	return int(base_damage * variance)

## 检查命中
func check_hit(skill: Skill) -> bool:
	return randf() <= skill.accuracy

## 检查状态触发
func check_status(skill: Skill) -> bool:
	if skill.status_effect == StatusEffect.NONE:
		return false
	return randf() <= skill.status_chance
