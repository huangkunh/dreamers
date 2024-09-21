extends CharacterBody3D

## 生命
@export var current_health: int = 100
## 速度: 关乎攻击顺序和闪避率
@export var fight_speed: int = 10
## 战斗LV: 关乎白刃战强度
@export var battle_LV = 10
## 强度: 关乎防御
@export var strength: int = 10
## 重力
@export var enemy_garvity: int = 1
## 战斗id
@export var fight_id: String

@onready var hurt_label: Label3D = $HurtLabel
@onready var animated_sprite3D: AnimatedSprite3D = $AnimatedSprite3D
@onready var local_player_name: Label3D = $LocalPlayerName
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var target_velocity: Vector3 = Vector3.ZERO
var fight_data


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
	#move_and_collide(target_velocity, false, 0.1, false, 1)
	pass


# 初始化怪物 位置, 纹理, 法线纹理, 默认动画
func init_enemy(enemy_data):
	position = enemy_data.enemy_position
	
	fight_speed = enemy_data.fight_speed
	current_health = enemy_data.current_health
	battle_LV = enemy_data.fight_speed
	strength = enemy_data.strength	
	fight_id = enemy_data.fight_id
	local_player_name.text = enemy_data.local_player_name
	
	var standar_material3D: StandardMaterial3D = StandardMaterial3D.new()
	standar_material3D.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	standar_material3D.normal_enabled = true
	standar_material3D.albedo_texture = load(enemy_data.albedo_texture_path)
	standar_material3D.normal_texture = load(enemy_data.normal_map_texture_path)
	animated_sprite3D.set_material_override(standar_material3D)
	animated_sprite3D.play(enemy_data.animated[0])	
	
	pass
	
func enemy_attack():
	pass


## 受到攻击
## fight_unit 攻击单位数据
## enemy_fight_unit 受到攻击单位数据
## weapons_tween 补间动画数据
func under_fire(fight_unit, enemy_fight_unit, weapons_tween):
	#var fight_unit = fighting_unit_map[fighting_id]
	var weapons = fight_unit.weapons
	var battle_LV = fight_unit.battle_LV
	var enemy_strength = enemy_fight_unit.strength
	var weapons_battle_LV = weapons.battle_LV
	var harm = weapons_battle_LV + battle_LV - enemy_strength
	if harm < 0:
		harm = 1
	enemy_fight_unit.current_health -= harm
	var enemy_health = enemy_fight_unit.current_health
	var enemy_scene = self
	var enemy_global_position = enemy_scene.global_position

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
	

## 攻击玩家
## tween 补间动画对象
func attack_player(tween):
	# 怪物
	var enemy_scene: CharacterBody3D = self
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
	
	tween.set_trans(Tween.TRANS_SINE)
	var audio_stream_player_3d: AudioStreamPlayer3D = enemy_scene.audio_stream_player_3d
	audio_stream_player_3d.stream = load("res://music/sound_effect/normal_attack.wav")
	
					# 怪物攻击动画
	tween.parallel().tween_property(animated_sprite3D, "material_overlay", standar_material3D, 0.1)
	tween.tween_property(animated_sprite3D, "material_overlay", material_override, 0.1)
	tween.parallel().tween_callback(audio_stream_player_3d._set_playing.bind(true))
	
