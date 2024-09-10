extends Node3D

@onready var enenies_manager: Node3D = $EnemiesManager
@onready var fight_speed_path: Path2D = $FightSpeedPath
@onready var fight_player_manager: Node3D = $FightPlayerManager
@onready var player_info_container: VBoxContainer = $PlayerInfo/PlayerInfoContainer

enum Attack_Type {
	MELEE, ## 近战
	REMOTE, ## 远程	
}

enum Attack_Target {
	FOE_ONE, ## 敌人 1
	SELF_ONE, ## 自己 1
}

var normal_attack = {
	"skill_name" : "普通一击", ## 攻击名字
	"attack_type" : Attack_Type.MELEE, ## 攻击类型
	"attack_target" : Attack_Target.FOE_ONE, ## 攻击目标
	"skill_strength" : 0.8 ## 技能强度
}

var e01_flame_guns = {
	"player_name": "e01_flame_guns", ## 玩家姓名
	"local_player_name": "火焰枪", ## 国际化姓名
	"skills": [normal_attack], ## 技能
	"confirm_player": false, ## 确认玩家
	"fight_speed": 10, ## 速度,影响攻击顺序
	"health": 100, ## 生命值
	"battle_LV": 10, ## 关乎白刃战强度
	"strength": 10, ## 影响防御
	"enemy_position": Vector3.ZERO, ## 生成位置
	"animated": ["e01_flame_guns_default"], ## 待机动画
	"albedo_texture_path": "res://sprite/ordinary_enemies/aoduo/e01_flame_guns.png", ## 精灵图
	"normal_map_texture_path": "res://sprite/ordinary_enemies/aoduo/e01_flame_guns_n.png", ## 法线贴图
}

var e02_cannon = {
	"player_name": "e02_cannon", ## 玩家姓名
	"local_player_name": "加农炮", ## 国际化姓名
	"skills": [normal_attack], ## 技能
	"confirm_player": false, ## 确认玩家
	"fight_speed": 5, ## 速度,影响攻击顺序
	"health": 60, ## 生命值
	"battle_LV": 13, ## 关乎白刃战强度
	"strength": 15, ## 影响防御
	"animated": ["e02_cannon_default"],
	"albedo_texture_path": "res://sprite/ordinary_enemies/aoduo/e02_cannon.png",
	"normal_map_texture_path": "res://sprite/ordinary_enemies/aoduo/e02_cannon_n.png",
}

var l01_giant_ants = {
	"player_name": "l01_giant_ants", ## 玩家姓名
	"local_player_name": "巨蚁", ## 国际化姓名
	"skills": [normal_attack], ## 技能
	"confirm_player": false, ## 确认玩家
	"fight_speed": 9, ## 速度,影响攻击顺序
	"health": 70, ## 生命值
	"battle_LV": 20, ## 关乎白刃战强度
	"strength": 19, ## 影响防御
	"animated": ["l01_giant_ants_default"],
	"albedo_texture_path": "res://sprite/ordinary_enemies/aoduo/l01_giant_ants.png",
	"normal_map_texture_path": "res://sprite/ordinary_enemies/aoduo/l01_giant_ants_n.png",
}

var l01_sour_ants = {
	"player_name": "l01_sour_ants", ## 玩家姓名
	"local_player_name": "酸蚁", ## 国际化姓名
	"skills": [normal_attack], ## 技能
	"confirm_player": false, ## 确认玩家
	"fight_speed": 20, ## 速度,影响攻击顺序
	"health": 150, ## 生命值
	"battle_LV": 25, ## 关乎白刃战强度
	"strength": 5, ## 影响防御	
	"animated": ["l01_sour_ants_default"],
	"albedo_texture_path": "res://sprite/ordinary_enemies/aoduo/l01_sour_ants.png",
	"normal_map_texture_path": "res://sprite/ordinary_enemies/aoduo/l01_sour_ants_n.png",
}

var l02_amoeba = {
	"player_name": "l02_amoeba", ## 玩家姓名
	"local_player_name": "变形虫", ## 国际化姓名
	"skills": [normal_attack], ## 技能
	"confirm_player": false, ## 确认玩家
	"fight_speed": 3, ## 速度,影响攻击顺序
	"health": 300, ## 生命值
	"battle_LV": 8, ## 关乎白刃战强度
	"strength": 5, ## 影响防御	
	"animated": ["l02_amoeba_default"],
	"albedo_texture_path": "res://sprite/ordinary_enemies/aoduo/l02_amoeba.png",
	"normal_map_texture_path": "res://sprite/ordinary_enemies/aoduo/l02_amoeba_n.png",
}

var enemies_init_data = {
	1: e01_flame_guns,
	2: e02_cannon,
	3: l01_giant_ants,
	4: l01_sour_ants,
	5: l02_amoeba,
}

var ray_ban_na = {
	"player_name": "ray_ban_na", ## 玩家姓名
	"local_player_name": "雷班纳", ## 国际化姓名
	"skills": [normal_attack], ## 技能
	"confirm_player": true, ## 确认玩家
	"fight_speed": 3, ## 速度,影响攻击顺序
	"max_health": 100, ## 最大生命值
	"min_health": 100, ## 最小生命值
	"current_health": 81, ## 当前生命值
	"battle_LV": 8, ## 关乎白刃战强度
	"strength": 5, ## 影响防御	
	"animated": ["ray_ban_na_default"],
	"albedo_texture_path": "res://sprite/battlers/fight_player.png",
	"normal_map_texture_path": "res://sprite/battlers/fight_player_n.png",
}

var fight_player_init_data = {
	0: ray_ban_na,
}

# 正在战斗的单位
var fighting_unit_map: Dictionary = {}

# 敌人场景
var enemy_scene_map = {}

# 玩家场景
var player_scene_map = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 生成怪物
	var generration_enemy_num = randi_range(1, 4)
	var enemies_size = enemies_init_data.size()
	var enemies_data_list = []
	for i in generration_enemy_num:
		var index = randi_range(1, enemies_size - 1)
		var enemy = enemies_init_data[index]
		var fight_id = enemy.player_name + "_" + str(i)
		enemy.fight_id = fight_id
		fighting_unit_map[fight_id] = enemy
		enemies_data_list.append(enemy)	
	
	var enemy_scene: Array = enenies_manager.generation_enemy(enemies_data_list)
	for enemy in enemy_scene:
		enemy_scene_map[enemy.fight_id] = enemy
	
	#生成玩家
	for i in range(fight_player_init_data.size()):
		var fight_player_data = fight_player_init_data[i]
		var fight_id = fight_player_data.player_name + "_" + str(i)
		fight_player_data.fight_id = fight_id
		fighting_unit_map[fight_id] = fight_player_data
		
	var player_scene = fight_player_manager.generation_fight_palyer(fight_player_init_data)
	for player in player_scene:
		player_scene_map[player.fight_id] = player
	
	#生成玩家信息(右上角)
	player_info_container.init_player_info(ray_ban_na)
	
	# 生成战斗进度
	fight_speed_path.init_fight_speed_Path(fighting_unit_map.values())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## 战斗
func _on_fight_speed_path_uint_fighting(fight_id) -> void:
	var fighting_unit = fighting_unit_map[fight_id]
	# 是玩家
	if fighting_unit.confirm_player:
		pass
	else: #是怪物
		var skill_index = randi_range(0, fighting_unit.skills.size() - 1)
		var skill = fighting_unit.skills[skill_index]
		if skill.attack_type == Attack_Type.MELEE:
			if skill.attack_type == Attack_Target.FOE_ONE:
				# 怪物
				var enemy_scene: CharacterBody3D = enemy_scene_map[fight_id]
				var animated_sprite3D: AnimatedSprite3D = enemy_scene.animated_sprite3D
				var material_override: StandardMaterial3D = animated_sprite3D.get_material_override()
				
				# 做插值动画的材质
				var standar_material3D: StandardMaterial3D = StandardMaterial3D.new()
				standar_material3D.transparency = material_override.transparency
				standar_material3D.normal_enabled = true
				standar_material3D.albedo_texture = material_override.albedo_texture
				standar_material3D.normal_texture = material_override.normal_texture
				standar_material3D.emission_enabled = true
				standar_material3D.emission = Color(1.0, 1.0, 1.0)
				
				# 怪物攻击动画 和音效
				var tween = animated_sprite3D.create_tween()
				var audio_stream_player_3d: AudioStreamPlayer3D = enemy_scene.audio_stream_player_3d
				audio_stream_player_3d.stream = load("res://music/sound_effect/normal_attack.wav")
				
				# 被攻击的玩家 动画
				var player_scene_index = randi_range(0, player_scene_map.size() - 1)
				var player_scene: CharacterBody3D = player_scene_map.values()[player_scene_index]
				var player_audio_stream_player_3d: AudioStreamPlayer3D = player_scene.audio_stream_player_3d
				player_audio_stream_player_3d.stream = load("res://music/sound_effect/attacked.wav")
				var player_position = player_scene.position
				var tween_position = Vector3(player_position)
				tween_position.x += 0.5
				
				tween.tween_property(animated_sprite3D, "material_overlay", standar_material3D, 0.1)
				tween.tween_property(animated_sprite3D, "material_overlay", material_override, 0.1)
				tween.tween_callback(audio_stream_player_3d._set_playing.bind(true))
				tween.tween_property(player_scene, "position", tween_position, 0.05)
				tween.tween_property(player_scene, "position", player_position, 0.05)
				tween.tween_callback(player_audio_stream_player_3d._set_playing.bind(true))
				
