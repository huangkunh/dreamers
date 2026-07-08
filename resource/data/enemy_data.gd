extends Node
## 敌人数据 (EnemyData)
## 包含普通敌人和赏金首数据，统一管理所有敌人配置

# 使用 AttackData 的枚举 (避免重复定义)

## ---- 奥多市周边敌人 ----
var l02_amoeba: Dictionary = {
	"player_name": "l02_amoeba",
	"local_player_name": "变形虫",
	"skills": [AttackData.normal_attack],
	"confirm_player": false,
	"fight_speed": 3,
	"current_health": 300,
	"max_health": 300,
	"battle_lv": 8,
	"strength": 5,
	"exp_reward": 15,
	"coin_reward": 25,
	"animated": ["l02_amoeba_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l02_amoeba.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l02_amoeba_n.png",
	"enemy_position": Vector3.ZERO,
}

var e01_flame_guns: Dictionary = {
	"player_name": "e01_flame_guns",
	"local_player_name": "火焰枪",
	"skills": [AttackData.normal_attack, AttackData.flame_breath],
	"confirm_player": false,
	"fight_speed": 10,
	"current_health": 100,
	"max_health": 100,
	"battle_lv": 10,
	"strength": 10,
	"exp_reward": 20,
	"coin_reward": 35,
	"animated": ["e01_flame_guns_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns_n.png",
	"enemy_position": Vector3.ZERO,
}

var e02_cannon: Dictionary = {
	"player_name": "e02_cannon",
	"local_player_name": "自行炮",
	"skills": [AttackData.normal_attack, AttackData.cannon_fire],
	"confirm_player": false,
	"fight_speed": 8,
	"current_health": 150,
	"max_health": 150,
	"battle_lv": 15,
	"strength": 12,
	"exp_reward": 30,
	"coin_reward": 50,
	"animated": ["e02_cannon_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon_n.png",
	"enemy_position": Vector3.ZERO,
}

var l01_giant_ants: Dictionary = {
	"player_name": "l01_giant_ants",
	"local_player_name": "巨型蚂蚁",
	"skills": [AttackData.normal_attack, AttackData.group_bite],
	"confirm_player": false,
	"fight_speed": 12,
	"current_health": 80,
	"max_health": 80,
	"battle_lv": 6,
	"strength": 8,
	"exp_reward": 12,
	"coin_reward": 15,
	"animated": ["l01_giant_ants_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_giant_ants.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_giant_ants_n.png",
	"enemy_position": Vector3.ZERO,
}

var l01_sour_ants: Dictionary = {
	"player_name": "l01_sour_ants",
	"local_player_name": "酸蚁",
	"skills": [AttackData.normal_attack, AttackData.acid_spit],
	"confirm_player": false,
	"fight_speed": 9,
	"current_health": 60,
	"max_health": 60,
	"battle_lv": 5,
	"strength": 6,
	"exp_reward": 10,
	"coin_reward": 12,
	"animated": ["l01_sour_ants_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_sour_ants.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_sour_ants_n.png",
	"enemy_position": Vector3.ZERO,
}

## ---- 荒野敌人 ----
var w01_desert_rat: Dictionary = {
	"player_name": "w01_desert_rat",
	"local_player_name": "沙漠鼠",
	"skills": [AttackData.normal_attack],
	"confirm_player": false,
	"fight_speed": 15,
	"current_health": 120,
	"max_health": 120,
	"battle_lv": 12,
	"strength": 10,
	"exp_reward": 25,
	"coin_reward": 40,
	"animated": ["w01_desert_rat_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/wasteland/w01_desert_rat.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/wasteland/w01_desert_rat_n.png",
	"enemy_position": Vector3.ZERO,
}

var w02_sand_worm: Dictionary = {
	"player_name": "w02_sand_worm",
	"local_player_name": "沙虫",
	"skills": [AttackData.normal_attack, AttackData.acid_spit],
	"confirm_player": false,
	"fight_speed": 6,
	"current_health": 350,
	"max_health": 350,
	"battle_lv": 18,
	"strength": 15,
	"exp_reward": 50,
	"coin_reward": 80,
	"animated": ["w02_sand_worm_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/wasteland/w02_sand_worm.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/wasteland/w02_sand_worm_n.png",
	"enemy_position": Vector3.ZERO,
}

var w03_mad_biker: Dictionary = {
	"player_name": "w03_mad_biker",
	"local_player_name": "暴走族",
	"skills": [AttackData.normal_attack, AttackData.flame_breath],
	"confirm_player": false,
	"fight_speed": 14,
	"current_health": 200,
	"max_health": 200,
	"battle_lv": 20,
	"strength": 18,
	"exp_reward": 60,
	"coin_reward": 100,
	"animated": ["w03_mad_biker_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/wasteland/w03_mad_biker.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/wasteland/w03_mad_biker_n.png",
	"enemy_position": Vector3.ZERO,
}

## ---- 赏金首 ----
var b01_rock_butterfly: Dictionary = {
	"player_name": "b01_rock_butterfly",
	"local_player_name": "巨蝶",
	"skills": [AttackData.normal_attack, AttackData.flame_breath, AttackData.acid_spit],
	"confirm_player": false,
	"fight_speed": 11,
	"current_health": 800,
	"max_health": 800,
	"battle_lv": 25,
	"strength": 20,
	"exp_reward": 200,
	"coin_reward": 500,
	"is_bounty": true,
	"bounty_id": "b01_rock_butterfly",
	"bounty_reward": 500,
	"animated": ["b01_rock_butterfly_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b01_rock_butterfly.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b01_rock_butterfly_n.png",
	"enemy_position": Vector3.ZERO,
}

var b02_mad_tank: Dictionary = {
	"player_name": "b02_mad_tank",
	"local_player_name": "失控坦克",
	"skills": [AttackData.cannon_fire, AttackData.tank_machine_gun, AttackData.normal_attack],
	"confirm_player": false,
	"fight_speed": 7,
	"current_health": 2000,
	"max_health": 2000,
	"battle_lv": 40,
	"strength": 35,
	"exp_reward": 500,
	"coin_reward": 1500,
	"is_bounty": true,
	"bounty_id": "b02_mad_tank",
	"bounty_reward": 1500,
	"animated": ["b02_mad_tank_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b02_mad_tank.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b02_mad_tank_n.png",
	"enemy_position": Vector3.ZERO,
}

var b03_ant_queen: Dictionary = {
	"player_name": "b03_ant_queen",
	"local_player_name": "蚁后",
	"skills": [AttackData.normal_attack, AttackData.acid_spit, AttackData.group_bite],
	"confirm_player": false,
	"fight_speed": 5,
	"current_health": 1500,
	"max_health": 1500,
	"battle_lv": 30,
	"strength": 25,
	"exp_reward": 350,
	"coin_reward": 1000,
	"is_bounty": true,
	"bounty_id": "b03_ant_queen",
	"bounty_reward": 1000,
	"animated": ["b03_ant_queen_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b03_ant_queen.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b03_ant_queen_n.png",
	"enemy_position": Vector3.ZERO,
}

## ---- 敌人编组 ----
var aoduo_enemies: Array = [l02_amoeba, e01_flame_guns, e02_cannon, l01_giant_ants, l01_sour_ants]
var wasteland_enemies: Array = [w01_desert_rat, w02_sand_worm, w03_mad_biker]
var bounty_enemies: Array = [b01_rock_butterfly, b02_mad_tank, b03_ant_queen]

var enemies_init_data: Dictionary = {
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

## 随机获取区域敌人 (用于遇敌)
func get_random_enemies(area: String, count: int = 1) -> Array:
	var pool := get_enemies_by_area(area)
	var result: Array = []
	for i in range(count):
		var idx := randi() % pool.size()
		var enemy := pool[idx].duplicate(true)
		# 重置HP (避免引用同一对象)
		enemy["current_health"] = enemy.get("max_health", 100)
		result.append(enemy)
	return result
