extends CharacterBody3D

## 重力
@export var gravity := 100	 
## 战斗id
@export var fight_id: String
## 战斗时的数据
@export var fight_player_data: Dictionary:
	set(data):
		fight_player_data = data
		
		# 处理生命
		var current_health = data.current_health
		var max_health = data.max_health
		if current_health <= 0:
			current_health = 0
			player_death()
		if current_health > max_health:
			current_health = max_health

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var hurt_label: Label3D = $HurtLabel

@onready var animated_sprite3D := $Animation

var target_velocity: Vector3 = Vector3.ZERO

var max_health: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	player_move(delta)
	
	
## 角色移动
## delta 帧间隔时间
func player_move(delta:float):
	if not is_on_floor():
		target_velocity.y -= gravity * delta
	 
	velocity = target_velocity
	move_and_slide()	
	

# 初始化玩家 位置, 纹理, 法线纹理, 默认动画
func init_fight_palyer(fight_player_init_data):
	fight_player_data = fight_player_init_data
	position = fight_player_init_data.fight_palyer_position
	
	max_health = fight_player_init_data.max_health
	fight_id = fight_player_init_data.fight_id
	
	var standar_material3D: StandardMaterial3D = StandardMaterial3D.new()
	standar_material3D.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	standar_material3D.normal_enabled = true
	standar_material3D.albedo_texture = load(fight_player_init_data.albedo_texture_path)
	standar_material3D.normal_texture = load(fight_player_init_data.normal_map_texture_path)
	animated_sprite3D.set_material_override(standar_material3D)
	animated_sprite3D.play(fight_player_init_data.animated[0])		
	pass
	
	
## 攻击敌人
## enemy_scene 敌人场景
## enemy_fight_unit 敌人单位数据
## weapons_tween 补间动画对象
func attack_enemy(enemy_scene, enemy_fight_unit, weapons_tween):
	var player_scene: CharacterBody3D = self
	var audio_stream_player3D: AudioStreamPlayer3D = player_scene.get_node("AudioStreamPlayer3D")
	var animation: AnimatedSprite3D = player_scene.get_node("Animation")
	var weapons_animated: AnimatedSprite3D = player_scene.get_node("WeaponsAnimated")
	var weapon: Sprite3D = player_scene.get_node("Weapon")
	
	var animation_global_position = animation.global_position
	#var enemy_scene = enemy_scene_map.values()[attack_pointer_index]
	#var enemy_fight_id = enemy_scene.fight_id
	#var enemy_fight_unit = fighting_unit_map[enemy_fight_id]
	var enemy_global_position = enemy_scene.global_position
	enemy_global_position.z += 0.2
	audio_stream_player3D.stream = load("res://music/sound_effect/weapon_stone.wav")

	audio_stream_player3D.playing = true
	weapons_animated.global_position = animation_global_position
	weapons_animated.play("stone")
	weapon.visible = true	
	
	weapons_tween.set_trans(Tween.TRANS_SINE)
	weapons_tween.tween_property(weapons_animated, "visible", true, 0.1)
	weapons_tween.tween_property(weapons_animated, "global_position", enemy_global_position, 0.4)
	weapons_tween.tween_callback(weapons_animated.set_animation.bind("stone_hits"))
	weapons_tween.tween_property(weapons_animated, "visible", false, 1.0)
	weapons_tween.tween_property(weapon, "visible", false, 0.1)
	
	
## 受到攻击
## tween 补间动画对象
func under_fire(tween):
	var player_scene = self
	var player_audio_stream_player_3d: AudioStreamPlayer3D = player_scene.audio_stream_player_3d
	player_audio_stream_player_3d.stream = load("res://music/sound_effect/attacked.wav")
	var player_position = player_scene.position
	var tween_position = Vector3(player_position)
	tween_position.x += 0.5
	
	# 玩家受击动画
	tween.tween_property(player_scene, "position", tween_position, 0.05).set_delay(0.5)
	tween.tween_property(player_scene, "position", player_position, 0.05)
	tween.parallel().tween_callback(player_audio_stream_player_3d._set_playing.bind(true))
	

## 受击数值动画
## skill_hurt 受到伤害
## tween 补间动画对象
func under_fire_label(skill_hurt, tween):
	# 伤害 数字动画 血量变化
	var player_scene = self
	#var skill_hurt = (skill.skill_strength * fighting_unit.battle_LV) as int
	var hurt_label: Label3D = player_scene.hurt_label
	var hurt_label_position = hurt_label.position
	hurt_label.text = str(skill_hurt)
	var hurt_label_position_tween = Vector3(hurt_label_position)
	hurt_label_position_tween.x += 0.5
	hurt_label_position_tween.y += 0.5
	tween.tween_property(hurt_label, "visible", true, 0.5)
	tween.parallel().tween_property(hurt_label, "position", hurt_label_position_tween, 0.5)
	tween.parallel().tween_property(hurt_label, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
	hurt_label_position_tween.x += 0.1
	hurt_label_position_tween.y -= 0.3
	tween.tween_property(hurt_label, "position", hurt_label_position_tween, 0.5)
	tween.parallel().tween_property(hurt_label, "scale", Vector3.ONE, 0.1)
	
	# 恢复伤害数字
	tween.tween_callback(hurt_label.set_visible.bind(false))
	tween.parallel().tween_callback(hurt_label.set_position.bind(hurt_label_position))
	
	
## 角色死亡
func player_death():
	var standar_material3D: StandardMaterial3D = StandardMaterial3D.new()
	standar_material3D.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	standar_material3D.normal_enabled = true
	standar_material3D.albedo_texture = load("res://sprite/battlers/player_death.png")
	standar_material3D.normal_texture = load("res://sprite/battlers/player_death_n.png")
	animated_sprite3D.set_material_override(standar_material3D)
	animated_sprite3D.play("player_death")	
	

## 设置战斗数据
## data 战斗数据
func set_fight_player_data(data):
	fight_player_data = data
	
