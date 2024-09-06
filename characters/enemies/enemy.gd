extends CharacterBody3D

## 生命
@export var health :int = 100
## 速度 : 关乎攻击顺序和闪避率
@export var speed :int = 10
## 战斗LV : 关乎白刃战强度
@export var battle_LV = 10
## 强度 : 关乎防御
@export var strength :int = 10
## 重力
@export var enemy_garvity :int = 1

@onready var animated_sprite3D: AnimatedSprite3D = $AnimatedSprite3D

var target_velocity :Vector3 = Vector3.ZERO


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
	
	speed = enemy_data.speed
	health = enemy_data.health
	battle_LV = enemy_data.speed
	strength = enemy_data.strength	
	
	var standar_material3D : StandardMaterial3D = StandardMaterial3D.new()
	standar_material3D.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	standar_material3D.normal_enabled = true
	standar_material3D.albedo_texture = load(enemy_data.albedo_textture_path)
	standar_material3D.normal_texture = load(enemy_data.normal_map_textture_path)
	animated_sprite3D.set_material_override(standar_material3D)
	animated_sprite3D.play(enemy_data.animated[0])	
	
	pass
