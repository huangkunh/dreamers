extends Node

#var AttackData = preload("res://resource/data/AttackData.gd")

var e01_flame_guns = {
	"player_name": "e01_flame_guns", ## 玩家姓名
	"local_player_name": "火焰枪", ## 国际化姓名
	"skills": [AttackData.normal_attack], ## 技能
	"confirm_player": false, ## 确认玩家
	"fight_speed": 10, ## 速度,影响攻击顺序
	"current_health": 100, ## 生命值
	"battle_lv": 10, ## 关乎白刃战强度
	"strength": 10, ## 影响防御
	"enemy_position": Vector3.ZERO, ## 生成位置
	"animated": ["e01_flame_guns_default"], ## 待机动画
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns.png", ## 精灵图
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e01_flame_guns_n.png", ## 法线贴图
}

var e02_cannon = {
	"player_name": "e02_cannon", ## 玩家姓名
	"local_player_name": "加农炮", ## 国际化姓名
	"skills": [AttackData.normal_attack], ## 技能
	"confirm_player": false, ## 确认玩家
	"fight_speed": 5, ## 速度,影响攻击顺序
	"current_health": 60, ## 生命值
	"battle_lv": 13, ## 关乎白刃战强度
	"strength": 15, ## 影响防御
	"animated": ["e02_cannon_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/e02_cannon_n.png",
}

var l01_giant_ants = {
	"player_name": "l01_giant_ants", ## 玩家姓名
	"local_player_name": "巨蚁", ## 国际化姓名
	"skills": [AttackData.normal_attack], ## 技能
	"confirm_player": false, ## 确认玩家
	"fight_speed": 9, ## 速度,影响攻击顺序
	"current_health": 70, ## 生命值
	"battle_lv": 20, ## 关乎白刃战强度
	"strength": 19, ## 影响防御
	"animated": ["l01_giant_ants_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_giant_ants.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_giant_ants_n.png",
}

var l01_sour_ants = {
	"player_name": "l01_sour_ants", ## 玩家姓名
	"local_player_name": "酸蚁", ## 国际化姓名
	"skills": [AttackData.normal_attack], ## 技能
	"confirm_player": false, ## 确认玩家
	"fight_speed": 20, ## 速度,影响攻击顺序
	"current_health": 150, ## 生命值
	"battle_lv": 25, ## 关乎白刃战强度
	"strength": 5, ## 影响防御	
	"animated": ["l01_sour_ants_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_sour_ants.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l01_sour_ants_n.png",
}

var l02_amoeba = {
	"player_name": "l02_amoeba", ## 玩家姓名
	"local_player_name": "变形虫", ## 国际化姓名
	"skills": [AttackData.normal_attack], ## 技能
	"confirm_player": false, ## 确认玩家
	"fight_speed": 3, ## 速度,影响攻击顺序
	"current_health": 300, ## 生命值
	"battle_lv": 8, ## 关乎白刃战强度
	"strength": 5, ## 影响防御	
	"animated": ["l02_amoeba_default"],
	"albedo_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l02_amoeba.png",
	"normal_map_texture_path": "res://resource/sprite/ordinary_enemies/aoduo/l02_amoeba_n.png",
}

var enemies_init_data = {
	0: l02_amoeba,
	1: e01_flame_guns,
	2: e02_cannon,
	3: l01_giant_ants,
	4: l01_sour_ants,
}
