extends Node
## 攻击/技能数据 (AttackData)
## 定义所有攻击类型和技能
## 作为 Autoload 单例运行

enum Attack_Type {
	MELEE,   ## 近战
	REMOTE,  ## 远程
}

enum Attack_Target {
	FOE_ONE,   ## 单体敌人
	SELF_ONE,  ## 自己单体
	FOE_ALL,   ## 全体敌人
	ALLY_ONE,  ## 单体队友
	ALLY_ALL,  ## 全体队友
}

## ---- 武器定义 ----
const weapons_slingshot: Dictionary = {
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"battle_lv": 8,
}

const weapons_pistol: Dictionary = {
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"battle_lv": 15,
}

const weapons_rifle: Dictionary = {
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"battle_lv": 30,
}

const weapons_bat: Dictionary = {
	"attack_type": Attack_Type.MELEE,
	"attack_target": Attack_Target.FOE_ONE,
	"battle_lv": 10,
}

## ---- 技能定义 ----
const normal_attack: Dictionary = {
	"skill_name": "普通一击",
	"attack_type": Attack_Type.MELEE,
	"attack_target": Attack_Target.FOE_ONE,
	"skill_strength": 0.8,
}

const flame_breath: Dictionary = {
	"skill_name": "火焰喷射",
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"skill_strength": 1.2,
}

const cannon_fire: Dictionary = {
	"skill_name": "炮弹轰击",
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"skill_strength": 1.5,
}

const acid_spit: Dictionary = {
	"skill_name": "酸液吐击",
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"skill_strength": 0.9,
}

const group_bite: Dictionary = {
	"skill_name": "群体撕咬",
	"attack_type": Attack_Type.MELEE,
	"attack_target": Attack_Target.FOE_ALL,
	"skill_strength": 0.6,
}

const heal_self: Dictionary = {
	"skill_name": "自我修复",
	"attack_type": Attack_Type.MELEE,
	"attack_target": Attack_Target.SELF_ONE,
	"skill_strength": -1.0,  ## 负值表示治疗
}

const tank_cannon: Dictionary = {
	"skill_name": "主炮射击",
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"skill_strength": 2.0,
}

const tank_machine_gun: Dictionary = {
	"skill_name": "机枪扫射",
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ALL,
	"skill_strength": 0.5,
}
