extends Node3D

@export var enemy_scene :PackedScene

@onready var enemies_marker = {
	1 : $"EnemiesMarker1",
	2 : $"EnemiesMarker2",
	3 : $"EnemiesMarker3",
	4 : $"EnemiesMarker4",
}

var e01_flame_guns = {
	"speed" : 10, ## 速度,影响攻击顺序
	"health" : 100, ## 生命值
	"battle_LV" : 10, ## 关乎白刃战强度
	"strength" : 10, ## 影响防御
	"enemy_position" : Vector3.ZERO, ## 生成位置
	"animated" : ["e01_flame_guns_default"], ## 待机动画
	"albedo_textture_path" : "res://sprite/ordinary_enemies/aoduo/e01_flame_guns.png", ## 精灵图
	"normal_map_textture_path" : "res://sprite/ordinary_enemies/aoduo/e01_flame_guns_n.png", ## 法线贴图
}

var e02_cannon = {
	"speed" : 5, ## 速度,影响攻击顺序
	"health" : 60, ## 生命值
	"battle_LV" : 13, ## 关乎白刃战强度
	"strength" : 15, ## 影响防御
	"animated" : ["e02_cannon_default"],
	"albedo_textture_path" : "res://sprite/ordinary_enemies/aoduo/e02_cannon.png",
	"normal_map_textture_path" : "res://sprite/ordinary_enemies/aoduo/e02_cannon_n.png",
}

var l01_giant_ants = {
	"speed" : 9, ## 速度,影响攻击顺序
	"health" : 70, ## 生命值
	"battle_LV" : 20, ## 关乎白刃战强度
	"strength" : 19, ## 影响防御
	"animated" : ["l01_giant_ants_default"],
	"albedo_textture_path" : "res://sprite/ordinary_enemies/aoduo/l01_giant_ants.png",
	"normal_map_textture_path" : "res://sprite/ordinary_enemies/aoduo/l01_giant_ants_n.png",
}

var l01_sour_ants = {
	"speed" : 20, ## 速度,影响攻击顺序
	"health" : 150, ## 生命值
	"battle_LV" : 25, ## 关乎白刃战强度
	"strength" : 5, ## 影响防御	
	"animated" : ["l01_sour_ants_default"],
	"albedo_textture_path" : "res://sprite/ordinary_enemies/aoduo/l01_sour_ants.png",
	"normal_map_textture_path" : "res://sprite/ordinary_enemies/aoduo/l01_sour_ants_n.png",
}

var l02_amoeba = {
	"speed" : 3, ## 速度,影响攻击顺序
	"health" : 300, ## 生命值
	"battle_LV" : 8, ## 关乎白刃战强度
	"strength" : 5, ## 影响防御	
	"animated" : ["l02_amoeba_default"],
	"albedo_textture_path" : "res://sprite/ordinary_enemies/aoduo/l02_amoeba.png",
	"normal_map_textture_path" : "res://sprite/ordinary_enemies/aoduo/l02_amoeba_n.png",
}

var enemies_init_data = {
	1 : e01_flame_guns,
	2 : e02_cannon,
	3 : l01_giant_ants,
	4 : l01_sour_ants,
	5 : l02_amoeba,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#generation_enemy_position(Vector3(-0.106442, 0.839271, 2.57322))
	generation_enemy()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generation_enemy():
	var enemy_num = randi_range(1, 4)
	
	var enemies_marker_p :Node3D =  enemies_marker[enemy_num]
	for marker3D in enemies_marker_p.get_children():
		generation_enemy_position(marker3D.position)


func generation_enemy_position(marker_position):
		var enemy_data_no = randi_range(1, 5)
		enemies_init_data[enemy_data_no].enemy_position = marker_position
				
		var enemy :CharacterBody3D = enemy_scene.instantiate()
		enemy._ready()
		enemy.init_enemy(enemies_init_data[enemy_data_no])
		add_child(enemy)
	
