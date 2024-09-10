extends CharacterBody3D

## 移动速度
@export var movement_speed := 200
## 重力
@export var gravity := 100
## 生命
@export var current_health: int = 100
## 速度: 关乎攻击顺序和闪避率
@export var speed: int = 10
## 战斗LV: 关乎白刃战强度
@export var battle_LV = 10
## 强度: 关乎防御
@export var strength: int = 10
## 战斗id
@export var fight_id: String

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var animated_sprite3D := $Animation

var target_velocity: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	player_move(delta)
	
func player_move(delta:float):
	var vector := Vector3.ZERO
		
	target_velocity = vector * movement_speed * delta
	
	if not is_on_floor():
		target_velocity.y -= gravity * delta
	
	if vector.length() >0:
		animated_sprite3D.play()		
	else:
		animated_sprite3D.stop()
	
	velocity = target_velocity
	move_and_slide()	
	

# 初始化玩家 位置, 纹理, 法线纹理, 默认动画
func init_fight_palyer(fight_player_init_data):
	position = fight_player_init_data.fight_palyer_position
	
	speed = fight_player_init_data.fight_speed
	current_health = fight_player_init_data.current_health
	battle_LV = fight_player_init_data.fight_speed
	strength = fight_player_init_data.strength	
	fight_id = fight_player_init_data.fight_id
	
	var standar_material3D: StandardMaterial3D = StandardMaterial3D.new()
	standar_material3D.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	standar_material3D.normal_enabled = true
	standar_material3D.albedo_texture = load(fight_player_init_data.albedo_texture_path)
	standar_material3D.normal_texture = load(fight_player_init_data.normal_map_texture_path)
	animated_sprite3D.set_material_override(standar_material3D)
	animated_sprite3D.play(fight_player_init_data.animated[0])	
	
	pass
	
