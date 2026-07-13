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
        "ai_behavior": 0,  # RANDOM AI
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
        "ai_behavior": 0,  # RANDOM AI
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
        "ai_behavior": 0,  # RANDOM AI
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
        "ai_behavior": 0,  # RANDOM AI
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
        "ai_behavior": 0,  # RANDOM AI
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
        "ai_behavior": 0,  # RANDOM AI
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
        "ai_behavior": 0,  # RANDOM AI
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
        "ai_behavior": 0,  # RANDOM AI
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
        "ai_behavior": 4,  # BOSS AI
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
        "ai_behavior": 4,  # BOSS AI
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
        "ai_behavior": 4,  # BOSS AI
        "bounty_id": "b03_ant_queen",
        "bounty_reward": 1000,
        "animated": ["b03_ant_queen_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b03_ant_queen.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b03_ant_queen_n.png",
        "enemy_position": Vector3.ZERO,
}

## ---- 新增敌人 (扩展种类) ----

## 变异蝙蝠 (荒野)
var w04_mutant_bat: Dictionary = {
        "player_name": "w04_mutant_bat",
        "local_player_name": "变异蝙蝠",
        "skills": [AttackData.normal_attack],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 25,
        "current_health": 60,
        "max_health": 60,
        "battle_lv": 12,
        "strength": 8,
        "exp_reward": 15,
        "coin_reward": 8,
        "animated": ["w04_mutant_bat_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_giant_ants.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_giant_ants_n.png",
        "enemy_position": Vector3.ZERO,
}

## 机械蜘蛛 (工厂)
var f01_spider_bot: Dictionary = {
        "player_name": "f01_spider_bot",
        "local_player_name": "机械蜘蛛",
        "skills": [AttackData.normal_attack],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 15,
        "current_health": 120,
        "max_health": 120,
        "battle_lv": 18,
        "strength": 14,
        "exp_reward": 25,
        "coin_reward": 15,
        "animated": ["f01_spider_bot_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon_n.png",
        "enemy_position": Vector3.ZERO,
}

## 古代守卫 (遗迹)
var r01_ancient_guard: Dictionary = {
        "player_name": "r01_ancient_guard",
        "local_player_name": "古代守卫",
        "skills": [AttackData.normal_attack],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 8,
        "current_health": 200,
        "max_health": 200,
        "battle_lv": 25,
        "strength": 20,
        "exp_reward": 40,
        "coin_reward": 25,
        "animated": ["r01_ancient_guard_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns_n.png",
        "enemy_position": Vector3.ZERO,
}

## 铁甲蛙 (奥多周边)
var l03_iron_frog: Dictionary = {
        "player_name": "l03_iron_frog",
        "local_player_name": "铁甲蛙",
        "skills": [AttackData.normal_attack],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 5,
        "current_health": 150,
        "max_health": 150,
        "battle_lv": 7,
        "strength": 8,
        "exp_reward": 18,
        "coin_reward": 20,
        "weakness": "fire",
        "animated": ["l03_iron_frog_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l02_amoeba.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l02_amoeba_n.png",
        "enemy_position": Vector3.ZERO,
}

## 泥人 (奥多周边)
var l04_mud_doll: Dictionary = {
        "player_name": "l04_mud_doll",
        "local_player_name": "泥人",
        "skills": [AttackData.normal_attack, AttackData.acid_spit],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 4,
        "current_health": 200,
        "max_health": 200,
        "battle_lv": 9,
        "strength": 10,
        "exp_reward": 22,
        "coin_reward": 28,
        "animated": ["l04_mud_doll_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l02_amoeba.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l02_amoeba_n.png",
        "enemy_position": Vector3.ZERO,
}

## 金属鼠 (荒野)
var w05_metal_rat: Dictionary = {
        "player_name": "w05_metal_rat",
        "local_player_name": "金属鼠",
        "skills": [AttackData.normal_attack, AttackData.normal_attack],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 20,
        "current_health": 100,
        "max_health": 100,
        "battle_lv": 14,
        "strength": 12,
        "exp_reward": 28,
        "coin_reward": 45,
        "animated": ["w05_metal_rat_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/wasteland/w01_desert_rat.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/wasteland/w01_desert_rat_n.png",
        "enemy_position": Vector3.ZERO,
}

## 巨蝎 (荒野)
var w06_giant_scorpion: Dictionary = {
        "player_name": "w06_giant_scorpion",
        "local_player_name": "巨蝎",
        "skills": [AttackData.normal_attack, AttackData.acid_spit],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 10,
        "current_health": 280,
        "max_health": 280,
        "battle_lv": 16,
        "strength": 16,
        "exp_reward": 40,
        "coin_reward": 65,
        "animated": ["w06_giant_scorpion_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/wasteland/w02_sand_worm.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/wasteland/w02_sand_worm_n.png",
        "enemy_position": Vector3.ZERO,
}

## 安保机器人 (工厂)
var f02_security_bot: Dictionary = {
        "player_name": "f02_security_bot",
        "local_player_name": "安保机器人",
        "skills": [AttackData.normal_attack, AttackData.stun_gun],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 8,
        "current_health": 180,
        "max_health": 180,
        "battle_lv": 20,
        "strength": 18,
        "exp_reward": 45,
        "coin_reward": 70,
        "animated": ["f02_security_bot_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon_n.png",
        "enemy_position": Vector3.ZERO,
}

## 锈蚀无人机 (工厂)
var f03_rusted_drone: Dictionary = {
        "player_name": "f03_rusted_drone",
        "local_player_name": "锈蚀无人机",
        "skills": [AttackData.normal_attack, AttackData.flame_breath],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 22,
        "current_health": 90,
        "max_health": 90,
        "battle_lv": 17,
        "strength": 14,
        "exp_reward": 30,
        "coin_reward": 50,
        "animated": ["f03_rusted_drone_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns_n.png",
        "enemy_position": Vector3.ZERO,
}

## 兵蚁 (蚁穴)
var l05_soldier_ant: Dictionary = {
        "player_name": "l05_soldier_ant",
        "local_player_name": "兵蚁",
        "skills": [AttackData.normal_attack, AttackData.group_bite],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 10,
        "current_health": 100,
        "max_health": 100,
        "battle_lv": 10,
        "strength": 10,
        "exp_reward": 18,
        "coin_reward": 20,
        "animated": ["l05_soldier_ant_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_giant_ants.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_giant_ants_n.png",
        "enemy_position": Vector3.ZERO,
}

## 幼虫 (蚁穴)
var l06_larva: Dictionary = {
        "player_name": "l06_larva",
        "local_player_name": "幼虫",
        "skills": [AttackData.normal_attack],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 6,
        "current_health": 50,
        "max_health": 50,
        "battle_lv": 5,
        "strength": 5,
        "exp_reward": 8,
        "coin_reward": 10,
        "animated": ["l06_larva_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_sour_ants.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_sour_ants_n.png",
        "enemy_position": Vector3.ZERO,
}

## 哨戒炮台 (古代遗迹)
var r02_sentry_gun: Dictionary = {
        "player_name": "r02_sentry_gun",
        "local_player_name": "哨戒炮台",
        "skills": [AttackData.cannon_fire, AttackData.tank_machine_gun],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 7,
        "current_health": 150,
        "max_health": 150,
        "battle_lv": 22,
        "strength": 18,
        "exp_reward": 35,
        "coin_reward": 55,
        "animated": ["r02_sentry_gun_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon_n.png",
        "enemy_position": Vector3.ZERO,
}

## 全息守卫 (古代遗迹)
var r03_hologram_guard: Dictionary = {
        "player_name": "r03_hologram_guard",
        "local_player_name": "全息守卫",
        "skills": [AttackData.normal_attack, AttackData.stun_gun, AttackData.flame_breath],
        "confirm_player": false,
        "ai_behavior": 0,  # RANDOM AI
        "fight_speed": 12,
        "current_health": 250,
        "max_health": 250,
        "battle_lv": 28,
        "strength": 22,
        "exp_reward": 60,
        "coin_reward": 90,
        "animated": ["r03_hologram_guard_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns_n.png",
        "enemy_position": Vector3.ZERO,
}

## 沙漠之狼 (赏金首b05)
var b05_desert_wolf: Dictionary = {
        "player_name": "b05_desert_wolf",
        "local_player_name": "沙漠之狼",
        "skills": [AttackData.normal_attack, AttackData.flame_breath, AttackData.group_bite],
        "confirm_player": false,
        "fight_speed": 18,
        "current_health": 1200,
        "max_health": 1200,
        "battle_lv": 28,
        "strength": 25,
        "exp_reward": 300,
        "coin_reward": 600,
        "is_bounty": true,
        "ai_behavior": 4,  # BOSS AI
        "bounty_id": "b05_desert_wolf",
        "bounty_reward": 600,
        "animated": ["b05_desert_wolf_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b01_rock_butterfly.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b01_rock_butterfly_n.png",
        "enemy_position": Vector3.ZERO,
}

## 诺亚化身 (赏金首b07 - 最终BOSS)
var b07_noah_avatar: Dictionary = {
        "player_name": "b07_noah_avatar",
        "local_player_name": "诺亚化身",
        "skills": [AttackData.normal_attack, AttackData.flame_breath, AttackData.acid_spit, AttackData.cannon_fire, AttackData.group_bite],
        "confirm_player": false,
        "fight_speed": 10,
        "current_health": 3000,
        "max_health": 3000,
        "battle_lv": 50,
        "strength": 40,
        "exp_reward": 2000,
        "coin_reward": 5000,
        "is_bounty": true,
        "ai_behavior": 4,  # BOSS AI
        "bounty_id": "b07_noah_avatar",
        "bounty_reward": 5000,
        "animated": ["b07_noah_avatar_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b03_ant_queen.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b03_ant_queen_n.png",
        "enemy_position": Vector3.ZERO,
}

## ---- 敌人编组 ----
var aoduo_enemies: Array = [l02_amoeba, e01_flame_guns, e02_cannon, l01_giant_ants, l01_sour_ants, l03_iron_frog, l04_mud_doll]
var wasteland_enemies: Array = [w01_desert_rat, w02_sand_worm, w03_mad_biker, w04_mutant_bat, w05_metal_rat, w06_giant_scorpion]
var factory_enemies: Array = [e02_cannon, l02_amoeba, e01_flame_guns, b01_rock_butterfly, f01_spider_bot, f02_security_bot, f03_rusted_drone]
var ant_nest_enemies: Array = [l01_giant_ants, l01_sour_ants, l02_amoeba, l05_soldier_ant, l06_larva]
var ancient_ruins_enemies: Array = [e02_cannon, b01_rock_butterfly, l02_amoeba, e01_flame_guns, r01_ancient_guard, r02_sentry_gun, r03_hologram_guard]
var bounty_enemies: Array = [b01_rock_butterfly, b02_mad_tank, b03_ant_queen, b04_amorphous, b05_desert_wolf, b07_noah_avatar]

## 不定形 (古代遗迹BOSS - 赏金首b04)
var b04_amorphous: Dictionary = {
        "player_name": "b04_amorphous",
        "local_player_name": "不定形",
        "skills": [AttackData.normal_attack, AttackData.acid_spit, AttackData.group_bite],
        "confirm_player": false,
        "fight_speed": 12,
        "current_health": 800,
        "max_health": 800,
        "battle_lv": 35,
        "strength": 30,
        "exp_reward": 200,
        "coin_reward": 0,
        "animated": ["b04_amorphous_default"],
        "albedo_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b03_ant_queen.png",
        "normal_map_texture_path": "res://resource/sprite/ordinary_enemies/bounty/b03_ant_queen_n.png",
        "enemy_position": Vector3.ZERO,
        "is_bounty": true,
        "ai_behavior": 4,  # BOSS AI
        "bounty_id": "b04_amorphous",
        "bounty_reward": 3000,
}

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
        11: b04_amorphous,
        12: l03_iron_frog,
        13: l04_mud_doll,
        14: w05_metal_rat,
        15: w06_giant_scorpion,
        16: f02_security_bot,
        17: f03_rusted_drone,
        18: l05_soldier_ant,
        19: l06_larva,
        20: r02_sentry_gun,
        21: r03_hologram_guard,
        22: b05_desert_wolf,
        23: b07_noah_avatar,
}

## 根据区域获取敌人列表
func get_enemies_by_area(area: String) -> Array:
        match area:
                "aoduo": return aoduo_enemies
                "wasteland": return wasteland_enemies
                "factory": return factory_enemies
                "factory_ruins": return factory_enemies
                "ant_nest": return ant_nest_enemies
                "ancient_ruins": return ancient_ruins_enemies
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
                var enemy: Dictionary = pool[idx].duplicate(true)
                # 重置HP (避免引用同一对象)
                enemy["current_health"] = enemy.get("max_health", 100)
                result.append(enemy)
        return result

## ---- 敌人专属掉落表 (Metal Max原作特色) ----
## 每个敌人有特定的掉落物，格式: [{"id", "name", "chance", "count_min", "count_max"}]
var enemy_drops: Dictionary = {
        "l02_amoeba": [
                {"id": "slime_gel", "name": "黏液凝胶", "chance": 0.3, "count_min": 1, "count_max": 2},
                {"id": "potion", "name": "恢复药", "chance": 0.15, "count_min": 1, "count_max": 1},
        ],
        "e01_flame_guns": [
                {"id": "gun_barrel", "name": "枪管", "chance": 0.25, "count_min": 1, "count_max": 1},
                {"id": "potion", "name": "恢复药", "chance": 0.2, "count_min": 1, "count_max": 2},
        ],
        "e02_cannon": [
                {"id": "cannon_parts", "name": "炮管碎片", "chance": 0.3, "count_min": 1, "count_max": 2},
                {"id": "repair_kit", "name": "修理包", "chance": 0.1, "count_min": 1, "count_max": 1},
        ],
        "l01_giant_ants": [
                {"id": "ant_mandible", "name": "蚁颚", "chance": 0.35, "count_min": 1, "count_max": 2},
                {"id": "potion", "name": "恢复药", "chance": 0.15, "count_min": 1, "count_max": 1},
        ],
        "l01_sour_ants": [
                {"id": "acid_sac", "name": "酸囊", "chance": 0.3, "count_min": 1, "count_max": 1},
                {"id": "antidote", "name": "解毒药", "chance": 0.2, "count_min": 1, "count_max": 1},
        ],
        "w01_desert_rat": [
                {"id": "rat_tail", "name": "鼠尾", "chance": 0.3, "count_min": 1, "count_max": 2},
                {"id": "potion", "name": "恢复药", "chance": 0.2, "count_min": 1, "count_max": 2},
        ],
        "w02_sand_worm": [
                {"id": "worm_skin", "name": "虫皮", "chance": 0.35, "count_min": 1, "count_max": 2},
                {"id": "energy_drink", "name": "能量饮料", "chance": 0.15, "count_min": 1, "count_max": 1},
        ],
        "w03_mad_biker": [
                {"id": "biker_helmet", "name": "骑士头盔", "chance": 0.2, "count_min": 1, "count_max": 1},
                {"id": "coins_medium", "name": "中袋金币", "chance": 0.4, "count_min": 20, "count_max": 50},
        ],
        "w04_mutant_bat": [
                {"id": "bat_wing", "name": "蝙蝠翅膀", "chance": 0.3, "count_min": 1, "count_max": 2},
        ],
        "w05_metal_rat": [
                {"id": "metal_scrap", "name": "金属碎片", "chance": 0.4, "count_min": 1, "count_max": 3},
        ],
        "w06_giant_scorpion": [
                {"id": "scorpion_tail", "name": "蝎尾", "chance": 0.3, "count_min": 1, "count_max": 1},
                {"id": "antidote", "name": "解毒药", "chance": 0.25, "count_min": 1, "count_max": 2},
        ],
        "f01_spider_bot": [
                {"id": "spider_leg", "name": "机械蜘蛛腿", "chance": 0.3, "count_min": 1, "count_max": 2},
                {"id": "machine_part", "name": "机械零件", "chance": 0.2, "count_min": 1, "count_max": 1},
        ],
        "f02_security_bot": [
                {"id": "security_chip", "name": "安保芯片", "chance": 0.25, "count_min": 1, "count_max": 1},
                {"id": "repair_kit", "name": "修理包", "chance": 0.15, "count_min": 1, "count_max": 1},
        ],
        "f03_rusted_drone": [
                {"id": "drone_rotor", "name": "无人机旋翼", "chance": 0.3, "count_min": 1, "count_max": 2},
                {"id": "fuel_barrel", "name": "燃料桶", "chance": 0.2, "count_min": 1, "count_max": 1},
        ],
        "l05_soldier_ant": [
                {"id": "soldier_ant_head", "name": "兵蚁头颅", "chance": 0.3, "count_min": 1, "count_max": 1},
                {"id": "ant_chitin", "name": "蚁壳", "chance": 0.25, "count_min": 1, "count_max": 2},
        ],
        "l06_larva": [
                {"id": "larva_meat", "name": "幼虫肉", "chance": 0.4, "count_min": 1, "count_max": 2},
        ],
        "r01_ancient_guard": [
                {"id": "ancient_plate", "name": "古代甲片", "chance": 0.25, "count_min": 1, "count_max": 1},
                {"id": "energy_cell", "name": "能量电池", "chance": 0.2, "count_min": 1, "count_max": 2},
        ],
        "r02_sentry_gun": [
                {"id": "sentry_barrel", "name": "炮管", "chance": 0.3, "count_min": 1, "count_max": 1},
                {"id": "ancient_chip", "name": "古代芯片", "chance": 0.15, "count_min": 1, "count_max": 1},
        ],
        "r03_hologram_guard": [
                {"id": "hologram_core", "name": "全息核心", "chance": 0.2, "count_min": 1, "count_max": 1},
                {"id": "energy_cell", "name": "能量电池", "chance": 0.25, "count_min": 1, "count_max": 2},
        ],
        ## 赏金首专属掉落
        "b01_rock_butterfly": [
                {"id": "butterfly_wing", "name": "巨蝶翅膀", "chance": 1.0, "count_min": 1, "count_max": 1},
                {"id": "poison_gland", "name": "毒腺", "chance": 0.5, "count_min": 1, "count_max": 2},
                {"id": "coins_large", "name": "大袋金币", "chance": 0.8, "count_min": 50, "count_max": 100},
        ],
        "b02_mad_tank": [
                {"id": "tank_treads", "name": "坦克履带", "chance": 1.0, "count_min": 1, "count_max": 1},
                {"id": "heavy_cannon", "name": "重型炮管", "chance": 0.5, "count_min": 1, "count_max": 1},
                {"id": "coins_large", "name": "大袋金币", "chance": 0.8, "count_min": 80, "count_max": 150},
        ],
        "b03_ant_queen": [
                {"id": "queen_antenna", "name": "蚁后触角", "chance": 1.0, "count_min": 1, "count_max": 1},
                {"id": "royal_jelly", "name": "蜂王浆", "chance": 0.6, "count_min": 1, "count_max": 2},
                {"id": "coins_large", "name": "大袋金币", "chance": 0.8, "count_min": 60, "count_max": 120},
        ],
        "b04_amorphous": [
                {"id": "amorphous_core", "name": "不定形核心", "chance": 1.0, "count_min": 1, "count_max": 1},
                {"id": "ancient_chip", "name": "古代芯片", "chance": 0.7, "count_min": 1, "count_max": 3},
                {"id": "coins_huge", "name": "巨袋金币", "chance": 0.8, "count_min": 100, "count_max": 200},
        ],
        "b05_desert_wolf": [
                {"id": "wolf_fang", "name": "狼牙", "chance": 1.0, "count_min": 1, "count_max": 2},
                {"id": "wolf_pelt", "name": "狼皮", "chance": 0.6, "count_min": 1, "count_max": 1},
                {"id": "coins_large", "name": "大袋金币", "chance": 0.8, "count_min": 40, "count_max": 80},
        ],
        "b07_noah_avatar": [
                {"id": "noah_memory", "name": "诺亚记忆芯片", "chance": 1.0, "count_min": 1, "count_max": 1},
                {"id": "ancient_chip", "name": "古代芯片", "chance": 1.0, "count_min": 3, "count_max": 5},
                {"id": "coins_huge", "name": "巨袋金币", "chance": 1.0, "count_min": 200, "count_max": 500},
        ],
}

## 获取敌人专属掉落
func get_enemy_drops(enemy_id: String) -> Array:
        return enemy_drops.get(enemy_id, [])

## 计算敌人掉落 (用于战斗中)
func calculate_enemy_drops(enemy_id: String) -> Array:
        var drops := []
        var table = get_enemy_drops(enemy_id)
        for drop in table:
                if randf() <= drop.chance:
                        var count = randi_range(drop.count_min, drop.count_max)
                        drops.append({
                                "id": drop.id,
                                "name": drop.name,
                                "count": count,
                        })
        return drops
