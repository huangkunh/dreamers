extends Node
## 商店物品数据 (ShopData)
## 定义各商店的物品库存

## 创建基础物品
func _create_item(item_id: String, item_name: String, desc: String, type: int, price: int, atk: int = 0, def: int = 0, spd: int = 0) -> Dictionary:
	return {
		"id": item_id,
		"name": item_name,
		"description": desc,
		"type": type,
		"price": price,
		"attack": atk,
		"defense": def,
		"speed": spd,
		"stackable": type == 0,  # 消耗品可堆叠
	}

## 奥多市 - 武器店
var aoduo_weapon_shop: Array = [
	# 武器
	{
		"id": "weapon_pistol",
		"name": "手枪",
		"description": "最基础的远程武器，威力一般但可靠。",
		"type": 1,  # WEAPON
		"price": 200,
		"attack": 15,
		"defense": 0,
		"speed": 0,
		"stackable": false,
	},
	{
		"id": "weapon_rifle",
		"name": "步枪",
		"description": "射程远、威力较大的军用步枪。",
		"type": 1,
		"price": 500,
		"attack": 30,
		"defense": 0,
		"speed": 0,
		"stackable": false,
	},
	{
		"id": "weapon_bat",
		"name": "球棒",
		"description": "木制球棒，近战武器中最便宜的选择。",
		"type": 1,
		"price": 80,
		"attack": 10,
		"defense": 0,
		"speed": 0,
		"stackable": false,
	},
	{
		"id": "weapon_knife",
		"name": "军刀",
		"description": "锋利的军刀，近战攻击力不错。",
		"type": 1,
		"price": 150,
		"attack": 12,
		"defense": 2,
		"speed": 1,
		"stackable": false,
	},
]

## 奥多市 - 防具店
var aoduo_armor_shop: Array = [
	{
		"id": "armor_leather",
		"name": "皮甲",
		"description": "简单的皮革护甲，提供基础防护。",
		"type": 2,  # ARMOR
		"price": 120,
		"attack": 0,
		"defense": 8,
		"speed": 0,
		"stackable": false,
	},
	{
		"id": "armor_combat",
		"name": "战斗服",
		"description": "军用战斗服，防御力较好。",
		"type": 2,
		"price": 350,
		"attack": 0,
		"defense": 15,
		"speed": 0,
		"stackable": false,
	},
	{
		"id": "armor_bullet",
		"name": "防弹背心",
		"description": "可抵御子弹伤害的特制背心。",
		"type": 2,
		"price": 600,
		"attack": 0,
		"defense": 25,
		"speed": -1,
		"stackable": false,
	},
]

## 奥多市 - 道具店
var aoduo_item_shop: Array = [
	{
		"id": "item_potion_s",
		"name": "恢复药(小)",
		"description": "恢复50HP的药水。",
		"type": 0,  # CONSUMABLE
		"price": 30,
		"attack": 0,
		"defense": 0,
		"speed": 0,
		"stackable": true,
	},
	{
		"id": "item_potion_m",
		"name": "恢复药(中)",
		"description": "恢复150HP的药水。",
		"type": 0,
		"price": 80,
		"attack": 0,
		"defense": 0,
		"speed": 0,
		"stackable": true,
	},
	{
		"id": "item_potion_l",
		"name": "恢复药(大)",
		"description": "恢复500HP的药水。",
		"type": 0,
		"price": 200,
		"attack": 0,
		"defense": 0,
		"speed": 0,
		"stackable": true,
	},
	{
		"id": "item_antidote",
		"name": "解毒剂",
		"description": "解除中毒状态。",
		"type": 0,
		"price": 25,
		"attack": 0,
		"defense": 0,
		"speed": 0,
		"stackable": true,
	},
	{
		"id": "item_fuel",
		"name": "燃料桶",
		"description": "恢复50点战车燃料。",
		"type": 0,
		"price": 50,
		"attack": 0,
		"defense": 0,
		"speed": 0,
		"stackable": true,
	},
	{
		"id": "item_ammo",
		"name": "弹药箱",
		"description": "补充10发战车主炮弹药。",
		"type": 0,
		"price": 40,
		"attack": 0,
		"defense": 0,
		"speed": 0,
		"stackable": true,
	},
]

## 奥多市 - 饰品店
var aoduo_accessory_shop: Array = [
	{
		"id": "acc_speed_boots",
		"name": "加速靴",
		"description": "提升移动速度的魔法靴子。",
		"type": 3,  # ACCESSORY
		"price": 300,
		"attack": 0,
		"defense": 0,
		"speed": 3,
		"stackable": false,
	},
	{
		"id": "acc_power_ring",
		"name": "力量戒指",
		"description": "增强攻击力的神秘戒指。",
		"type": 3,
		"price": 500,
		"attack": 5,
		"defense": 0,
		"speed": 0,
		"stackable": false,
	},
	{
		"id": "acc_guard_necklace",
		"name": "守护项链",
		"description": "增强防御力的护身符。",
		"type": 3,
		"price": 450,
		"attack": 0,
		"defense": 8,
		"speed": 0,
		"stackable": false,
	},
]

## 获取商店数据
func get_shop_items(shop_id: String) -> Array:
	match shop_id:
		"aoduo_weapon": return aoduo_weapon_shop
		"aoduo_armor": return aoduo_armor_shop
		"aoduo_item": return aoduo_item_shop
		"aoduo_accessory": return aoduo_accessory_shop
		_: return []
