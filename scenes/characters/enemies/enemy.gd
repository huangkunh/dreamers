extends CharacterBody3D

## 重力
@export var enemy_garvity: int = 1
## 战斗id
@export var fight_id: String
## 战斗的敌人数据
@export var fight_enemy_data: Dictionary

@onready var hurt_label: Label3D = $HurtLabel
@onready var animated_sprite3D: AnimatedSprite3D = $AnimatedSprite3D
@onready var local_player_name: Label3D = $LocalPlayerName
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var target_velocity: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var position = Vector3.ZERO
	#init_enemy(position, albedo_textture, normal_textture, null)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_on_floor():
		var y = enemy_garvity * delta
		target_velocity.y -= y

	velocity = target_velocity
	move_and_slide()
	pass


# 初始化怪物 位置, 纹理, 法线纹理, 默认动画
func init_enemy(enemy_data):
	position = enemy_data.enemy_position
	fight_enemy_data = enemy_data
	
	fight_id = enemy_data.fight_id
	if local_player_name == null:
		local_player_name = get_node_or_null("LocalPlayerName")
	if local_player_name != null:
		local_player_name.text = enemy_data.local_player_name
	
	var standar_material3D: StandardMaterial3D = StandardMaterial3D.new()
	standar_material3D.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	standar_material3D.normal_enabled = true
	standar_material3D.albedo_texture = load(enemy_data.albedo_texture_path)
	standar_material3D.normal_texture = load(enemy_data.normal_map_texture_path)
	if animated_sprite3D == null:
		animated_sprite3D = get_node_or_null("AnimatedSprite3D")
	if animated_sprite3D == null:
		push_error("[Enemy] 缺少 AnimatedSprite3D 节点，无法初始化敌人贴图")
		return
	animated_sprite3D.set_material_override(standar_material3D)
	animated_sprite3D.play(enemy_data.animated[0])		
	pass


## 受到攻击
## fight_unit 攻击单位数据
## enemy_fight_unit 受到攻击单位数据
## weapons_tween 补间动画数据
## bool 死亡状态
func under_fire(fight_unit, enemy_fight_unit, weapons_tween)-> bool:
	#var fight_unit = fighting_unit_map[fighting_id]
	var weapons = fight_unit.weapons
	var battle_lv = fight_unit.battle_lv
	var enemy_strength = enemy_fight_unit.strength
	var weapons_battle_lv = weapons.battle_lv
	var harm = weapons_battle_lv + battle_lv - enemy_strength
	if harm < 0:
		harm = 1
	var enemy_scene = self
	var enemy_global_position = enemy_scene.global_position
	enemy_fight_unit.current_health -= harm
	if enemy_fight_unit.current_health <= 0:
		enemy_fight_unit.current_health = 0

	var hurt_label: Label3D = enemy_scene.hurt_label
	hurt_label.global_position = enemy_global_position
	var hurt_label_position = hurt_label.position
	hurt_label.text = str(harm)
	var hurt_label_position_tween = Vector3(hurt_label_position)
	hurt_label_position_tween.x -= 0.05
	hurt_label_position_tween.y += 0.05
	weapons_tween.tween_property(hurt_label, "visible", true, 0.5)
	weapons_tween.parallel().tween_property(hurt_label, "position", hurt_label_position_tween, 0.5)
	weapons_tween.parallel().tween_property(hurt_label, "scale", Vector3(1.5, 1.5, 1.5), 0.1)
	hurt_label_position_tween.x -= 0.05
	hurt_label_position_tween.y -= 0.05
	weapons_tween.tween_property(hurt_label, "position", hurt_label_position_tween, 0.5)
	weapons_tween.parallel().tween_property(hurt_label, "scale", Vector3.ONE, 0.1)
	weapons_tween.tween_callback(hurt_label.set_visible.bind(false))
	
	fight_enemy_data = enemy_fight_unit
	return enemy_fight_unit.current_health <= 0
	

## 攻击玩家
## tween 补间动画对象
func attack_player(tween):
	# 敌人闪烁颜色动画
	enemy_flashing_color(tween, Color(0.5, 0.5, 0.5, 0.8), 1)
	
	# 音效
	play_audio_se(tween, "res://music/sound_effect/normal_attack.wav")


## 敌人闪烁颜色动画
## target_color 目标颜色
## flash_times 闪烁次数
func enemy_flashing_color(tween, target_color, flash_times: int):
	if flash_times <= 0:
		return
			
	# 做插值动画的材质
	var material_override: StandardMaterial3D = animated_sprite3D.get_material_override()
	var standar_material3D: StandardMaterial3D = StandardMaterial3D.new()
	standar_material3D.transparency = material_override.transparency
	standar_material3D.normal_enabled = true
	standar_material3D.albedo_texture = material_override.albedo_texture
	standar_material3D.normal_texture = material_override.normal_texture
	standar_material3D.emission_enabled = true
	standar_material3D.emission = target_color
	
	tween.set_trans(Tween.TRANS_SINE)
	for i in flash_times:
		# 怪物攻击动画
		tween.tween_property(animated_sprite3D, "material_overlay", standar_material3D, 0.1)
		tween.tween_property(animated_sprite3D, "material_overlay", material_override, 0.22)
			

## 播放音效
## tween 补间动画对象
## stream_path 音效文件路径
func play_audio_se(tween, stream_path):
	audio_stream_player_3d.stream = load(stream_path)
	tween.parallel().tween_callback(audio_stream_player_3d._set_playing.bind(true))


## 敌人死亡
## tween 补间动画对象
func enemy_death(tween: Tween):
	enemy_flashing_color(tween, Color(1.0, 0.0, 0.0), 1)
	play_audio_se(tween, "res://music/sound_effect/enemy_defeat.wav")
	tween.tween_callback(self.queue_free)
