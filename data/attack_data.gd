extends Node

enum Attack_Type {
	MELEE, ## 近战
	REMOTE, ## 远程	
}

enum Attack_Target {
	FOE_ONE, ## 敌人 1
	SELF_ONE, ## 自己 1
}

# 弹弓
const weapons_slingshot: Dictionary = {
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"battle_lv": 8, ## 关乎白刃战强度
}

# 普通攻击
const normal_attack = {
	"skill_name" : "普通一击", ## 攻击名字
	"attack_type" : Attack_Type.MELEE, ## 攻击类型
	"attack_target" : Attack_Target.FOE_ONE, ## 攻击目标
	"skill_strength" : 0.8 ## 技能强度
}
