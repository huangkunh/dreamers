extends CharacterBody3D
## 玩家控制器 (Player)
## 8方向移动 + 像素动画 + 交互检测
## 与 player.tscn 兼容 (使用 $Animation AnimatedSprite3D)

## 移动速度 (步行)
@export var walk_speed: float = 5.0
## 移动速度 (战车中)
@export var tank_speed: float = 10.0
## 当前移动速度
@export var movement_speed: float = 5.0
## 重力
@export var gravity: float = 9.8

@onready var animated_sprite3D: AnimatedSprite3D = $Animation

## 当前朝向
var _facing: StringName = &"Down"
## 是否在移动
var _is_moving: bool = false
## 是否在战车中
var in_tank: bool = false:
	set(v):
		in_tank = v
		movement_speed = tank_speed if v else walk_speed

## 交互信号
signal interact_pressed
signal facing_changed(direction: StringName)

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	_handle_movement(delta)

func _handle_movement(delta: float) -> void:
	var input_vec := Vector2.ZERO
	
	# 8方向输入 (支持同时按多个键)
	if Input.is_action_pressed("move_up") or Input.is_action_pressed("ui_up"):
		input_vec.y -= 1
	if Input.is_action_pressed("move_down") or Input.is_action_pressed("ui_down"):
		input_vec.y += 1
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("ui_left"):
		input_vec.x -= 1
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("ui_right"):
		input_vec.x += 1
	
	# 对角线归一化 (防止快速移动)
	if input_vec.length() > 0:
		input_vec = input_vec.normalized()
		_is_moving = true
	else:
		_is_moving = false
	
	# 确定朝向 (优先水平方向, 保持与原版一致)
	var new_facing := _facing
	if input_vec.y < -0.5:
		new_facing = &"Up"
	elif input_vec.y > 0.5:
		new_facing = &"Down"
	
	if input_vec.x < -0.5:
		new_facing = &"Left"
	elif input_vec.x > 0.5:
		new_facing = &"Right"
	
	if new_facing != _facing:
		_facing = new_facing
		facing_changed.emit(_facing)
		if animated_sprite3D.sprite_frames and animated_sprite3D.sprite_frames.has_animation(_facing):
			animated_sprite3D.play(_facing)
	
	# 应用速度
	var target_velocity := Vector3.ZERO
	target_velocity.x = input_vec.x * movement_speed
	target_velocity.z = input_vec.y * movement_speed
	
	# 重力
	if not is_on_floor():
		target_velocity.y = velocity.y - gravity * delta
	
	velocity = target_velocity
	move_and_slide()
	
	# 动画播放/停止
	if _is_moving:
		if not animated_sprite3D.is_playing():
			animated_sprite3D.play(_facing)
	else:
		animated_sprite3D.stop()

## 获取当前朝向
func get_facing() -> StringName:
	return _facing

## 处理交互输入
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact_pressed.emit()
