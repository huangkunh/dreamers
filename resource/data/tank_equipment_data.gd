extends Node
## 战车装备数据 (TankEquipmentData)
## 定义所有战车装备: 主炮、副炮、引擎、装甲、C装置

## 装备类型
enum EquipType {
	MAIN_CANNON,   ## 主炮
	SUB_WEAPON,    ## 副武器 (机枪等)
	ENGINE,        ## 引擎
	ARMOR,         ## 装甲
	C_DEVICE,      ## C装置 (战斗辅助)
}

## C装置技能类型
enum CSkillType {
	INTERCEPT,     ## 迎击 (拦截敌方攻击)
	SUPPORT,       ## 援护 (为队友挡攻击)
	AUTO_RETURN,   ## 自动归返 (HP低时自动撤退)
	TARGET_LOCK,   ## 目标锁定 (提高命中率)
}

## ---- 主炮 ----
var main_cannons: Array = [
	{
		"id": "cannon_basic",
		"name": "基础主炮",
		"type": EquipType.MAIN_CANNON,
		"attack": 50,
		"ammo_max": 30,
		"price": 0,
		"description": "标准-issue 90mm 主炮，可靠但威力一般。",
	},
	{
		"id": "cannon_heavy",
		"name": "重炮 120mm",
		"type": EquipType.MAIN_CANNON,
		"attack": 80,
		"ammo_max": 20,
		"price": 2000,
		"description": "大口径主炮，威力强大但弹药有限。",
	},
	{
		"id": "cannon_double",
		"name": "双联装炮",
		"type": EquipType.MAIN_CANNON,
		"attack": 65,
		"ammo_max": 40,
		"price": 3500,
		"description": "双管齐射，均衡威力与弹药量。",
	},
	{
		"id": "cannon_railgun",
		"name": "电磁轨道炮",
		"type": EquipType.MAIN_CANNON,
		"attack": 120,
		"ammo_max": 15,
		"price": 8000,
		"description": "旧文明的科技，穿透力极强。",
	},
]

## ---- 副武器 ----
var sub_weapons: Array = [
	{
		"id": "mg_basic",
		"name": "基础机枪",
		"type": EquipType.SUB_WEAPON,
		"attack": 20,
		"ammo_max": 100,
		"price": 0,
		"description": "7.62mm 机枪，对轻装甲有效。",
	},
	{
		"id": "mg_heavy",
		"name": "重机枪 12.7mm",
		"type": EquipType.SUB_WEAPON,
		"attack": 35,
		"ammo_max": 80,
		"price": 1500,
		"description": "大口径机枪，压制火力。",
	},
	{
		"id": "mg_gatling",
		"name": "加特林机枪",
		"type": EquipType.SUB_WEAPON,
		"attack": 45,
		"ammo_max": 200,
		"price": 4000,
		"description": "六管旋转机枪，持续射击。",
	},
]

## ---- 引擎 ----
var engines: Array = [
	{
		"id": "engine_basic",
		"name": "标准引擎",
		"type": EquipType.ENGINE,
		"speed": 8,
		"fuel_efficiency": 1.0,
		"price": 0,
		"description": "基本型引擎，油耗正常。",
	},
	{
		"id": "engine_turbo",
		"name": "涡轮增压引擎",
		"type": EquipType.ENGINE,
		"speed": 12,
		"fuel_efficiency": 0.8,
		"price": 2500,
		"description": "提升速度，油耗略高。",
	},
	{
		"id": "engine_electric",
		"name": "电驱动引擎",
		"type": EquipType.ENGINE,
		"speed": 10,
		"fuel_efficiency": 0.5,
		"price": 6000,
		"description": "省油50%，旧文明技术。",
	},
]

## ---- 装甲 ----
var armors: Array = [
	{
		"id": "armor_basic",
		"name": "标准装甲",
		"type": EquipType.ARMOR,
		"defense": 30,
		"max_hp_bonus": 0,
		"price": 0,
		"description": "基础钢板装甲。",
	},
	{
		"id": "armor_composite",
		"name": "复合装甲",
		"type": EquipType.ARMOR,
		"defense": 50,
		"max_hp_bonus": 200,
		"price": 3000,
		"description": "复合材质，防御+HP双重提升。",
	},
	{
		"id": "armor_reactive",
		"name": "反应装甲",
		"type": EquipType.ARMOR,
		"defense": 70,
		"max_hp_bonus": 500,
		"price": 7000,
		"description": "爆炸反应装甲，顶级防护。",
	},
]

## ---- C装置 ----
var c_devices: Array = [
	{
		"id": "cdevice_basic",
		"name": "基础C装置",
		"type": EquipType.C_DEVICE,
		"skill": CSkillType.INTERCEPT,
		"skill_name": "迎击",
		"description": "概率拦截敌方攻击。",
		"price": 1000,
	},
	{
		"id": "cdevice_support",
		"name": "援护C装置",
		"type": EquipType.C_DEVICE,
		"skill": CSkillType.SUPPORT,
		"skill_name": "援护",
		"description": "为队友挡攻击，减轻伤害。",
		"price": 2000,
	},
	{
		"id": "cdevice_return",
		"name": "归返C装置",
		"type": EquipType.C_DEVICE,
		"skill": CSkillType.AUTO_RETURN,
		"skill_name": "自动归返",
		"description": "HP低于30%时自动撤退到基地。",
		"price": 2500,
	},
	{
		"id": "cdevice_lock",
		"name": "锁定C装置",
		"type": EquipType.C_DEVICE,
		"skill": CSkillType.TARGET_LOCK,
		"skill_name": "目标锁定",
		"description": "提高命中率20%。",
		"price": 3000,
	},
]

## 获取某类型所有装备
func get_equipment_by_type(type: int) -> Array:
	match type:
		EquipType.MAIN_CANNON: return main_cannons
		EquipType.SUB_WEAPON: return sub_weapons
		EquipType.ENGINE: return engines
		EquipType.ARMOR: return armors
		EquipType.C_DEVICE: return c_devices
		_: return []

## 根据ID获取装备
func get_equipment(equip_id: String) -> Dictionary:
	for equip_list in [main_cannons, sub_weapons, engines, armors, c_devices]:
		for equip in equip_list:
			if equip.get("id", "") == equip_id:
				return equip
	return {}
