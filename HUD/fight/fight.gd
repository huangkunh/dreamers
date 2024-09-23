extends Node3D

@onready var enenies_manager: Node3D = $EnemiesManager
@onready var fight_player_manager: Node3D = $FightPlayerManager
@onready var player_info_container: VBoxContainer = $FightHUD/PlayerInfo/PlayerInfoContainer
@onready var fight_speed_path: Path2D = $FightHUD/FightSpeedPath
@onready var skill_name_label: RichTextLabel = $FightHUD/SkillName
@onready var health_bar: PanelContainer = $FightHUD/PlayerInfo/PlayerInfoContainer/HealthBar
@onready var fight_menu: VBoxContainer = $FightHUD/FightMenu
@onready var fighting_player_marker: Marker3D = $FightPlayerManager/FightingPlayerMarker
@onready var fight_hud: Control = $FightHUD
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

enum Attack_Type {
	MELEE, ## 近战
	REMOTE, ## 远程	
}

enum Attack_Target {
	FOE_ONE, ## 敌人 1
	SELF_ONE, ## 自己 1
}

# 弹弓
var weapons_slingshot: Dictionary = {
	"attack_type": Attack_Type.REMOTE,
	"attack_target": Attack_Target.FOE_ONE,
	"battle_LV": 80, ## 关乎白刃战强度
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
	"current_health": 100, ## 生命值
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
	"current_health": 60, ## 生命值
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
	"current_health": 70, ## 生命值
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
	"current_health": 150, ## 生命值
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
	"current_health": 300, ## 生命值
	"battle_LV": 8, ## 关乎白刃战强度
	"strength": 5, ## 影响防御	
	"animated": ["l02_amoeba_default"],
	"albedo_texture_path": "res://sprite/ordinary_enemies/aoduo/l02_amoeba.png",
	"normal_map_texture_path": "res://sprite/ordinary_enemies/aoduo/l02_amoeba_n.png",
}

var enemies_init_data = {
	0: l02_amoeba,
	1: e01_flame_guns,
	2: e02_cannon,
	3: l01_giant_ants,
	4: l01_sour_ants,
}

var ray_ban_na = {
	"player_name": "ray_ban_na", ## 玩家姓名
	"local_player_name": "雷班纳", ## 国际化姓名
	"skills": [normal_attack], ## 技能
	"confirm_player": true, ## 确认玩家
	"fight_speed": 3, ## 速度,影响攻击顺序
	"max_health": 100, ## 最大生命值
	"min_health": 100, ## 最小生命值
	"current_health": 99, ## 当前生命值
	"battle_LV": 800, ## 关乎白刃战强度
	"strength": 5, ## 影响防御	
	"weapons": weapons_slingshot, ## 武器
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

# 正在战斗的id
var fighting_id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 生成怪物
	var generration_enemy_num = randi_range(1, 4)
	var enemies_size = enemies_init_data.size()
	var enemies_data_list = []
	for i in generration_enemy_num:
		var index = randi_range(1, enemies_size - 1)
		var enemy = enemies_init_data[index].duplicate(true)
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
	fighting_id = fight_id
	var fighting_unit = fighting_unit_map[fight_id]
	# 是玩家
	if fighting_unit.confirm_player:
		var player_scene: CharacterBody3D = player_scene_map[fight_id]
		fighting_player_marker.position.y = player_scene.position.y
		var tween = player_scene.create_tween()
		var player_name = fighting_unit.player_name
		tween.tween_property(player_scene, "position", fighting_player_marker.position, 0.5)
		tween.tween_callback(fight_menu.set_visible.bind(true))
		tween.tween_callback(fight_hud.pointer.set_visible.bind(true))
		
		pass
	else: #是怪物
		var skill_index = randi_range(0, fighting_unit.skills.size() - 1)
		var skill = fighting_unit.skills[skill_index]
		if skill.attack_type == Attack_Type.MELEE:
			if skill.attack_type == Attack_Target.FOE_ONE:
				enemy_melee_foe_one(skill)


## 敌人近战单体攻击
## skill 技能	
func enemy_melee_foe_one(skill):
	# 技能名字动画
	fight_hud.action_name_animation(skill.skill_name)
	
	# 攻击玩家
	var enemy_scene: CharacterBody3D = enemy_scene_map[fighting_id]
	var tween = enemy_scene.create_tween()
	enemy_scene.attack_player(tween)				
	
	# 被攻击的玩家
	var player_scene_index = randi_range(0, player_scene_map.size() - 1)
	var player_scene: CharacterBody3D = player_scene_map.values()[player_scene_index]
	player_scene.under_fire(tween)
	
	# 受到伤害数值动画
	var fighting_unit = fighting_unit_map[fighting_id]
	var skill_hurt = (skill.skill_strength * fighting_unit.battle_LV) as int
	player_scene.under_fire_label(skill_hurt, tween)
	
	# 玩家信息
	var fighting_unit_palyer = fighting_unit_map[player_scene.fight_id]
	fighting_unit_palyer.current_health -= skill_hurt
	if fighting_unit_palyer.current_health <= 0:
		fighting_unit_palyer.current_health = 0
	var current_health = str(fighting_unit_palyer.current_health)
	var max_health = str(fighting_unit_palyer.max_health)
	var health_info = player_info_container.find_child("HealthInfo")
	var health_label = "HP: " + current_health + " / " + max_health
	tween.parallel().tween_callback(health_bar.health_update.bind( - skill_hurt))
	tween.parallel().tween_callback(health_info.set_text.bind(health_label))
	tween.tween_callback(player_scene.set_fight_player_data.bind(fighting_unit_palyer))

	# 判断玩家是否存活
	if check_all_player_death():
		tween.parallel().tween_callback(self.all_player_death)
		return
	
	# 单位战斗结束
	tween.parallel().tween_callback(fight_speed_path.unit_fight_end.bind(fighting_id))
	
	
## 玩家远程单体攻击
## attack_pointer_index 敌人索引
func player_remote_foe_one(attack_pointer_index):
	# 武器攻击动画
	var player_scene: CharacterBody3D = player_scene_map[fighting_id]
	var enemy_scene = enemy_scene_map.values()[attack_pointer_index]
	var enemy_fight_id = enemy_scene.fight_id
	var enemy_fight_unit = fighting_unit_map[enemy_fight_id]
	var weapons_tween = player_scene.create_tween()
	player_scene.attack_enemy(enemy_scene, enemy_fight_unit, weapons_tween)

	# 造成伤害 = 武器白刃战LV + 人物白刃战LV - 目标强度
	var fight_unit = fighting_unit_map[fighting_id]
	var enemy_death = enemy_scene.under_fire(fight_unit, enemy_fight_unit, weapons_tween)
	
	# 怪物死亡
	if enemy_death:
		enemy_scene.enemy_death(weapons_tween)
		weapons_tween.tween_callback(clear_fight_data.bind(enemy_fight_id))
		# 校验所有敌人死亡
		if check_all_enemy_death():
			weapons_tween.tween_callback(self.all_enemy_death)
			return
		
	# 单位战斗结束
	weapons_tween.parallel().tween_callback(fight_speed_path.unit_fight_end.bind(fighting_id))


## 清除战斗数据
func clear_fight_data(fight_id):
	fighting_unit_map.erase(fight_id)
	enemy_scene_map.erase(fight_id)
	player_scene_map.erase(fight_id)
	fight_speed_path.unit_fight_death(fight_id)

		
## 检测所有敌人死亡
func check_all_enemy_death()-> bool:
	return enemy_scene_map.values().all(func(value):
			return value.fight_enemy_data.current_health <= 0)
	
	
## 所有敌人死亡
func all_enemy_death():
	audio_stream_player.stream = load("res://music/sound_effect/battle_victory_normal.wav")
	audio_stream_player.play()


## 检测玩家死亡			
func check_all_player_death()-> bool:
	var all_death = player_scene_map.values().all(func(value): 
			return value.fight_player_data.current_health <= 0)
	return all_death


## 全部玩家死亡
func all_player_death():
	audio_stream_player.stream = load("res://music/background_music/defeat.ogg")
	audio_stream_player.play()
