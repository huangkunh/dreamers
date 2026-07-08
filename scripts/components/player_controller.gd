extends CharacterBody3D
## 玩家控制器 (PlayerController)
## 8方向移动 + 动画 + 交互检测
## 附加到玩家节点上

## 移动速度 (步行)
@export var walk_speed: float = 4.0
## 移动速度 (战车中)
@export var tank_speed: float = 8.0
## 当前移动速度
@export var movement_speed: float = 4.0
## 重力
@export var gravity: float = 9.8
## 交互检测距离
@export var interact_range: float = 2.0

@onready var animated_sprite3d: AnimatedSprite3D = $Animation

## 当前朝向 (用于记录最后面向方向)
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
	# 确保有动画播放器
	if not animated_sprite3d:
		push_warning("PlayerController: 未找到 Animation 子节点")

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_gravity(delta)

## 处理8方向移动
func _handle_movement(delta: float) -> void:
	var input_vec := Vector2.ZERO

	# 读取输入 (支持8方向)
	if Input.is_action_pressed("move_up"):
		input_vec.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vec.y += 1
	if Input.is_action_pressed("move_left"):
		input_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vec.x += 1

	# 归一化对角线移动 (避免对角线更快)
	if input_vec.length() > 0:
		input_vec = input_vec.normalized()
		_is_moving = true
	else:
		_is_moving = false

	# 转换为3D速度 (x=左右, z=前后)
	var target_velocity := Vector3.ZERO
	target_velocity.x = input_vec.x * movement_speed
	target_velocity.z = input_vec.y * movement_speed

	# 应用速度
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	move_and_slide()

	# 更新动画
	_update_animation(input_vec)

## 处理重力
func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

## 更新动画方向
func _update_animation(input_vec: Vector2) -> void:
	if not animated_sprite3d:
		return

	# 确定朝向 (优先垂直方向)
	var new_facing: StringName = _facing
	if input_vec.y < -0.5:
		new_facing = &"Up"
	elif input_vec.y > 0.5:
		new_facing = &"Down"
	elif input_vec.x < -0.5:
		new_facing = &"Left"
	elif input_vec.x > 0.5:
		new_facing = &"Right"

	# 朝向变化时播放对应动画
	if new_facing != _facing:
		_facing = new_facing
		facing_changed.emit(_facing)
		if animated_sprite3d.sprite_frames and animated_sprite3d.sprite_frames.has_animation(_facing):
			animated_sprite3d.play(_facing)

	# 移动/停止动画
	if _is_moving:
		if not animated_sprite3d.is_playing():
			animated_sprite3d.play(_facing)
	else:
		animated_sprite3d.stop()

## 获取当前朝向
func get_facing() -> StringName:
	return _facing

## 处理交互输入
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact_pressed.emit()
		_try_interact()

## 尝试与前方物体交互
func _try_interact() -> void:
	print("[Player] 交互键按下，朝向: ", _facing)
