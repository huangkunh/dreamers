extends Node3D

@onready var enenies_manager : Node3D = $EnemiesManager
@onready var fight_speed_path : Path2D = $FightSpeedPath
@onready var fight_player_manager : Node3D = $FightPlayerManager
@onready var player_info_container : VBoxContainer = $PlayerInfo/PlayerInfoContainer

var e01_flame_guns = {
	"player_name" : "e01_flame_guns", ## 玩家姓名
	"fight_speed" : 10, ## 速度,影响攻击顺序
	"health" : 100, ## 生命值
	"battle_LV" : 10, ## 关乎白刃战强度
	"strength" : 10, ## 影响防御
	"enemy_position" : Vector3.ZERO, ## 生成位置
	"animated" : ["e01_flame_guns_default"], ## 待机动画
	"albedo_texture_path" : "res://sprite/ordinary_enemies/aoduo/e01_flame_guns.png", ## 精灵图
	"normal_map_texture_path" : "res://sprite/ordinary_enemies/aoduo/e01_flame_guns_n.png", ## 法线贴图
}

var e02_cannon = {
	"player_name" : "e02_cannon", ## 玩家姓名
	"fight_speed" : 5, ## 速度,影响攻击顺序
	"health" : 60, ## 生命值
	"battle_LV" : 13, ## 关乎白刃战强度
	"strength" : 15, ## 影响防御
	"animated" : ["e02_cannon_default"],
	"albedo_texture_path" : "res://sprite/ordinary_enemies/aoduo/e02_cannon.png",
	"normal_map_texture_path" : "res://sprite/ordinary_enemies/aoduo/e02_cannon_n.png",
}

var l01_giant_ants = {
	"player_name" : "l01_giant_ants", ## 玩家姓名
	"fight_speed" : 9, ## 速度,影响攻击顺序
	"health" : 70, ## 生命值
	"battle_LV" : 20, ## 关乎白刃战强度
	"strength" : 19, ## 影响防御
	"animated" : ["l01_giant_ants_default"],
	"albedo_texture_path" : "res://sprite/ordinary_enemies/aoduo/l01_giant_ants.png",
	"normal_map_texture_path" : "res://sprite/ordinary_enemies/aoduo/l01_giant_ants_n.png",
}

var l01_sour_ants = {
	"player_name" : "l01_sour_ants", ## 玩家姓名
	"fight_speed" : 20, ## 速度,影响攻击顺序
	"health" : 150, ## 生命值
	"battle_LV" : 25, ## 关乎白刃战强度
	"strength" : 5, ## 影响防御	
	"animated" : ["l01_sour_ants_default"],
	"albedo_texture_path" : "res://sprite/ordinary_enemies/aoduo/l01_sour_ants.png",
	"normal_map_texture_path" : "res://sprite/ordinary_enemies/aoduo/l01_sour_ants_n.png",
}

var l02_amoeba = {
	"player_name" : "l02_amoeba", ## 玩家姓名
	"fight_speed" : 3, ## 速度,影响攻击顺序
	"health" : 300, ## 生命值
	"battle_LV" : 8, ## 关乎白刃战强度
	"strength" : 5, ## 影响防御	
	"animated" : ["l02_amoeba_default"],
	"albedo_texture_path" : "res://sprite/ordinary_enemies/aoduo/l02_amoeba.png",
	"normal_map_texture_path" : "res://sprite/ordinary_enemies/aoduo/l02_amoeba_n.png",
}

var enemies_init_data = {
	1 : e01_flame_guns,
	2 : e02_cannon,
	3 : l01_giant_ants,
	4 : l01_sour_ants,
	5 : l02_amoeba,
}

var ray_ban_na = {
	"player_name" : "雷班纳", ## 玩家姓名
	"fight_speed" : 3, ## 速度,影响攻击顺序
	"max_health" : 100, ## 最大生命值
	"min_health" : 100, ## 最小生命值
	"current_health" : 81, ## 当前生命值
	"battle_LV" : 8, ## 关乎白刃战强度
	"strength" : 5, ## 影响防御	
	"animated" : ["ray_ban_na_default"],
	"albedo_texture_path" : "res://sprite/battlers/fight_player.png",
	"normal_map_texture_path" : "res://sprite/battlers/fight_player_n.png",
}

var fight_player_init_data = {
	1 : ray_ban_na,
}

var fight_player_list : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fight_player_list = enenies_manager.generation_enemy(enemies_init_data)
	fight_player_manager.generation_fight_palyer(fight_player_init_data)
	player_info_container.init_player_info(ray_ban_na)
	fight_player_list.append(ray_ban_na)
	fight_speed_path.init_fight_speed_Path(fight_player_list)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
