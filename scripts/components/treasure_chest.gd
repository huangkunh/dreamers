extends Area3D
## 宝箱组件 (TreasureChest)
## 可交互的宝箱，玩家靠近按E键打开获得奖励
## 支持金币/物品/装备/关键道具

## 奖励类型
enum RewardType {
	COINS,      ## 金币
	ITEM,       ## 物品
	EQUIPMENT,  ## 装备
	KEY_ITEM,   ## 关键道具
	HEAL,       ## 全恢复
}

## 宝箱ID (用于存档记录是否已开启)
@export var chest_id: String = ""
## 奖励类型
@export var reward_type: RewardType = RewardType.COINS
## 奖励数量 (金币) 或物品ID
@export var reward_value: String = "100"
## 奖励数量
@export var reward_amount: int = 1
## 宝箱显示名称
@export var display_name: String = "宝箱"
## 是否已打开
var _opened: bool = false

## 宝箱模型节点
var _chest_mesh: MeshInstance3D
## 交互提示标签
var _prompt_label: Label3D

func _ready() -> void:
	# 创建碰撞区域
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.2, 1.0, 1.2)
	collision.shape = box
	add_child(collision)

	# 创建宝箱模型
	_create_chest_mesh()

	# 创建交互提示
	_create_prompt_label()

	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# 检查是否已打开 (从存档)
	if not chest_id.is_empty() and GameData.game_flags.has("chest_" + chest_id):
		_opened = true
		_update_visual()

## 创建宝箱模型
func _create_chest_mesh() -> void:
	_chest_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.8, 0.6, 0.6)
	_chest_mesh.mesh = box
	_chest_mesh.position = Vector3(0, 0.3, 0)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.4, 0.2) if not _opened else Color(0.3, 0.25, 0.2)
	_chest_mesh.material_override = mat
	add_child(_chest_mesh)

	# 宝箱盖子
	var lid := MeshInstance3D.new()
	var lid_mesh := BoxMesh.new()
	lid_mesh.size = Vector3(0.85, 0.15, 0.65)
	lid.mesh = lid_mesh
	lid.position = Vector3(0, 0.675, 0)
	lid.material_override = mat
	add_child(lid)

## 创建交互提示
func _create_prompt_label() -> void:
	_prompt_label = Label3D.new()
	_prompt_label.text = "按 E 开启"
	_prompt_label.position = Vector3(0, 1.2, 0)
	_prompt_label.font_size = 24
	_prompt_label.outline_size = 6
	_prompt_label.outline_modulate = Color.BLACK
	_prompt_label.modulate = Color(1, 0.85, 0.3)
	_prompt_label.visible = false
	_prompt_label.no_depth_test = true
	_prompt_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(_prompt_label)

## 玩家进入范围
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not _opened:
		_prompt_label.visible = true

## 玩家离开范围
func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_prompt_label.visible = false

## 处理交互输入
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _prompt_label.visible and not _opened:
		_open_chest()

## 打开宝箱
func _open_chest() -> void:
	_opened = true
	_prompt_label.visible = false
	_update_visual()

	# 记录到存档
	if not chest_id.is_empty():
		GameData.game_flags["chest_" + chest_id] = true

	# 给予奖励
	var reward_text := _give_reward()
	print("[TreasureChest] 开启宝箱: " + display_name + " - " + reward_text)

	# 播放开启动画
	_play_open_animation()

## 给予奖励
func _give_reward() -> String:
	match reward_type:
		RewardType.COINS:
			var coins := int(reward_value)
			GameData.coins += coins
			GameData.coins_changed.emit(GameData.coins)
			return "获得 %d 金币" % coins

		RewardType.ITEM:
			# TODO: 从物品数据库创建物品
			return "获得物品: " + reward_value

		RewardType.EQUIPMENT:
			return "获得装备: " + reward_value

		RewardType.KEY_ITEM:
			GameData.game_flags["has_" + reward_value] = true
			return "获得关键道具: " + reward_value

		RewardType.HEAL:
			for member in GameData.party:
				member.current_hp = member.max_hp
			return "全队HP完全恢复"

	return "未知奖励"

## 更新视觉状态
func _update_visual() -> void:
	if _chest_mesh and _chest_mesh.material_override:
		var mat := _chest_mesh.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color = Color(0.3, 0.25, 0.2) if _opened else Color(0.6, 0.4, 0.2)

## 播放开启动画
func _play_open_animation() -> void:
	var tw := create_tween()
	# 宝箱轻微弹跳
	tw.tween_property(self, "position:y", position.y + 0.2, 0.15)
	tw.tween_property(self, "position:y", position.y, 0.15)
	# 闪光效果
	if _chest_mesh:
		var mat := _chest_mesh.material_override as StandardMaterial3D
		if mat:
			mat.emission_enabled = true
			mat.emission = Color(1, 0.85, 0.3)
			mat.emission_energy_multiplier = 2.0
			var tw2 := create_tween()
			tw2.tween_property(mat, "emission_energy_multiplier", 0.0, 0.5)
