extends Node
## 敌人数据 (EnemyData)
## 包含普通敌人和赏金首数据

enum Attack_Type {
	MELEE, ## 近战
	REMOTE, ## 远程
}

enum Attack_Target {
	FOE_ONE, ## 敌人 1
	SELF_ONE, ## 自己 1
	FOE_ALL, ## 敌人全体
}

# 弹弓
const weapons_slingshot: Dictionary = {
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"battle_lv": 8,
}

# 普通攻击
const normal_attack = {
	"skill_name": "普通一击",
	"attack_type": Attack_Type.MELEE,
	"attack_target": Attack_Target.FOE_ONE,
	"skill_strength": 0.8,
}

# 喷火
const flame_breath = {
	"skill_name": "火焰喷射",
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"skill_strength": 1.2,
}

# 炮击
const cannon_fire = {
	"skill_name": "炮弹轰击",
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"skill_strength": 1.5,
}

# 酸液攻击
const acid_spit = {
	"skill_name": "酸液吐击",
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"skill_strength": 0.9,
}

# 群体攻击
const group_bite = {
	"skill_name": "群体撕咬",
	"attack_type": Attack_Type.MELEE,
	"attack_target": Attack_Target.FOE_ALL,
	"skill_strength": 0.6,
}

# ===== 奥多区域 - 普通敌人 =====
var e01_flame_guns = {
	"player_name": "e01_flame_guns",
	"local_player_name": "火焰枪",
	"skills": [normal_attack, flame_breath],
	"confirm_player": false,
	"fight_speed": 10,
	"current_health": 100,
	"battle_lv": 10,
	"strength": 10,
	"enemy_position": Vector3.ZERO,
	"animated": ["e01_flame_guns_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns_n.png",
	"exp_reward": 15,
	"coin_reward": 25,
}

var e02_cannon = {
	"player_name": "e02_cannon",
	"local_player_name": "炮台",
	"skills": [normal_attack, cannon_fire],
	"confirm_player": false,
	"fight_speed": 6,
	"current_health": 150,
	"battle_lv": 15,
	"strength": 15,
	"animated": ["e02_cannon_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon_n.png",
	"exp_reward": 20,
	"coin_reward": 35,
}

var l01_giant_ants = {
	"player_name": "l01_giant_ants",
	"local_player_name": "巨型蚂蚁",
	"skills": [normal_attack, group_bite],
	"confirm_player": false,
	"fight_speed": 8,
	"current_health": 80,
	"battle_lv": 5,
	"strength": 5,
	"animated": ["l01_giant_ants_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_giant_ants.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_giant_ants_n.png",
	"exp_reward": 10,
	"coin_reward": 15,
}

var l01_sour_ants = {
	"player_name": "l01_sour_ants",
	"local_player_name": "酸液蚂蚁",
	"skills": [normal_attack, acid_spit],
	"confirm_player": false,
	"fight_speed": 7,
	"current_health": 60,
	"battle_lv": 4,
	"strength": 3,
	"animated": ["l01_sour_ants_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_sour_ants.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_sour_ants_n.png",
	"exp_reward": 8,
	"coin_reward": 12,
}

var l02_amoeba = {
	"player_name": "l02_amoeba",
	"local_player_name": "变形虫",
	"skills": [normal_attack, acid_spit],
	"confirm_player": false,
	"fight_speed": 3,
	"current_health": 300,
	"battle_lv": 8,
	"strength": 5,
	"animated": ["l02_amoeba_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l02_amoeba.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l02_amoeba_n.png",
	"exp_reward": 25,
	"coin_reward": 30,
}

# ===== 荒野区域 - 新敌人 =====
var w01_desert_rat = {
	"player_name": "w01_desert_rat",
	"local_player_name": "荒漠鼠",
	"skills": [normal_attack],
	"confirm_player": false,
	"fight_speed": 15,
	"current_health": 50,
	"battle_lv": 6,
	"strength": 4,
	"animated": [],
	"albedo_texture_path": "",
	"normal_map_texture_path": "",
	"exp_reward": 8,
	"coin_reward": 10,
}

var w02_sand_worm = {
	"player_name": "w02_sand_worm",
	"local_player_name": "沙虫",
	"skills": [normal_attack, acid_spit],
	"confirm_player": false,
	"fight_speed": 5,
	"current_health": 200,
	"battle_lv": 12,
	"strength": 8,
	"animated": [],
	"albedo_texture_path": "",
	"normal_map_texture_path": "",
	"exp_reward": 30,
	"coin_reward": 40,
}

var w03_mad_biker = {
	"player_name": "w03_mad_biker",
	"local_player_name": "暴走族",
	"skills": [normal_attack],
	"confirm_player": false,
	"fight_speed": 12,
	"current_health": 120,
	"battle_lv": 10,
	"strength": 8,
	"animated": [],
	"albedo_texture_path": "",
	"normal_map_texture_path": "",
	"exp_reward": 18,
	"coin_reward": 50,
}

# ===== 赏金首 =====
var b01_rock_butterfly = {
	"player_name": "b01_rock_butterfly",
	"local_player_name": "巨蝶",
	"skills": [normal_attack, flame_breath, acid_spit],
	"confirm_player": false,
	"fight_speed": 14,
	"current_health": 500,
	"battle_lv": 20,
	"strength": 15,
	"animated": [],
	"albedo_texture_path": "",
	"normal_map_texture_path": "",
	"exp_reward": 100,
	"coin_reward": 0,  # 赏金在公会领取
	"is_bounty": true,
	"bounty_id": "b01_rock_butterfly",
	"bounty_reward": 500,
}

var b02_mad_tank = {
	"player_name": "b02_mad_tank",
	"local_player_name": "失控坦克",
	"skills": [cannon_fire, normal_attack],
	"confirm_player": false,
	"fight_speed": 8,
	"current_health": 800,
	"battle_lv": 30,
	"strength": 25,
	"animated": [],
	"albedo_texture_path": "",
	"normal_map_texture_path": "",
	"exp_reward": 200,
	"coin_reward": 0,
	"is_bounty": true,
	"bounty_id": "b02_mad_tank",
	"bounty_reward": 1500,
}

var b03_ant_queen = {
	"player_name": "b03_ant_queen",
	"local_player_name": "蚁后",
	"skills": [normal_attack, group_bite, acid_spit],
	"confirm_player": false,
	"fight_speed": 6,
	"current_health": 600,
	"battle_lv": 25,
	"strength": 20,
	"animated": [],
	"albedo_texture_path": "",
	"normal_map_texture_path": "",
	"exp_reward": 150,
	"coin_reward": 0,
	"is_bounty": true,
	"bounty_id": "b03_ant_queen",
	"bounty_reward": 1000,
}

# ===== 敌人编组 =====
var aoduo_enemies = [l02_amoeba, e01_flame_guns, e02_cannon, l01_giant_ants, l01_sour_ants]
var wasteland_enemies = [w01_desert_rat, w02_sand_worm, w03_mad_biker]
var bounty_enemies = [b01_rock_butterfly, b02_mad_tank, b03_ant_queen]

var enemies_init_data = {
	0: l02_amoeba,
	1: e01_flame_guns,
	2: e02_cannon,
	3: l01_giant_ants,
	4: l01_sour_ants,
	5: w01_desert_rat,
	6: w02_sand_worm,
	7: w03_mad_biker,
	8: b01_rock_butterfly,
	9: b02_mad_tank,
	10: b03_ant_queen,
}

## 根据区域获取敌人列表
func get_enemies_by_area(area: String) -> Array:
	match area:
		"aoduo": return aoduo_enemies
		"wasteland": return wasteland_enemies
		_: return aoduo_enemies

## 获取赏金首列表
func get_bounty_enemies() -> Array:
	return bounty_enemies

## 根据ID获取敌人数据
func get_enemy_by_id(enemy_id: String) -> Dictionary:
	for enemy in enemies_init_data.values():
		if enemy.get("player_name", "") == enemy_id:
			return enemy
	return {}
