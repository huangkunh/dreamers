extends Node

#var attack_data = preload("res://scripts/data/attack_data.gd")

var ray_ban_na = {
        "player_name": "ray_ban_na", ## 玩家姓名
        "local_player_name": "雷班纳", ## 国际化姓名
        "exp_lv": 1, ## 经验等级
        "current_exp": 1, ## 当前经验值
        "max_exp": 55, ## 最大经验值
        "skills": [AttackData.normal_attack, AttackData.power_strike, AttackData.heal_ally, AttackData.defend, AttackData.poison_dagger], ## 技能
        "confirm_player": true, ## 确认玩家
        "fight_speed": 3, ## 速度,影响攻击顺序
        "max_health": 200, ## 最大生命值
        "min_health": 100, ## 最小生命值
        "current_health": 199, ## 当前生命值
        "battle_lv": 80, ## 关乎白刃战强度
        "strength": 5, ## 影响防御  
        "weapons": AttackData.weapons_slingshot, ## 武器
        "animated": ["ray_ban_na_default"],
        "albedo_texture_path": "res://resource/sprite/battlers/fight_player.png",
        "normal_map_texture_path": "res://resource/sprite/battlers/fight_player_n.png",
}

var fight_player_init_data = {
        0: ray_ban_na,
}
