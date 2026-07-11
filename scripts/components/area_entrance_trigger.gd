extends Area3D
## 区域入口触发器 (AreaEntranceTrigger)
## 玩家走到触发区域时自动切换到目标场景
## 用于场景间的无缝连接

## 目标场景名称 (GameFlow.SCENE_PATHS中的key)
@export var target_scene: String = ""
## 入口名称 (显示在提示中)
@export var entrance_name: String = ""
## 触发区域大小
@export var trigger_size: Vector3 = Vector3(2, 3, 2)
## 是否需要确认 (true=按E确认, false=自动触发)
@export var require_confirm: bool = false
## 是否显示提示
@export var show_hint: bool = true

## 提示标签
var _hint_label: Label3D
## 玩家是否在范围内
var _player_in_range: bool = false

func _ready() -> void:
	# 创建碰撞区域
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = trigger_size
	collision.shape = box
	add_child(collision)

	# 创建提示标签
	if show_hint:
		_hint_label = Label3D.new()
		_hint_label.text = "→ " + entrance_name if not entrance_name.is_empty() else "→ " + target_scene
		_hint_label.font_size = 24
		_hint_label.outline_modulate = Color.BLACK
		_hint_label.outline_size = 6
		_hint_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_hint_label.no_depth_test = true
		_hint_label.position = Vector3(0, 2, 0)
		_hint_label.modulate.a = 0.0
		_hint_label.visible = false
		add_child(_hint_label)

	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

## 玩家进入触发区域
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_range = true

	if show_hint and _hint_label:
		_hint_label.visible = true
		var tw := create_tween()
		tw.tween_property(_hint_label, "modulate:a", 1.0, 0.3)

	if not require_confirm:
		# 自动触发
		_trigger_scene_change()
	else:
		# 等待玩家按E确认
		print("[Entrance] 按E进入: " + entrance_name)

## 玩家离开触发区域
func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_range = false

	if show_hint and _hint_label:
		var tw := create_tween()
		tw.tween_property(_hint_label, "modulate:a", 0.0, 0.3)
		tw.tween_callback(func(): _hint_label.visible = false)

## 触发场景切换
func _trigger_scene_change() -> void:
	if target_scene.is_empty():
		return

	print("[Entrance] 进入区域: " + target_scene)
	# 标记区域为已访问
	GameData.game_flags["visited_" + target_scene] = true
	# 切换场景
	GameFlow.change_scene(target_scene)

func _process(_delta: float) -> void:
	# 如果需要确认且玩家在范围内
	if require_confirm and _player_in_range:
		if Input.is_action_just_pressed("interact"):
			_trigger_scene_change()
