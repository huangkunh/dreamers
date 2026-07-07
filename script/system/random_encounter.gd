extends Node
## 随机遇敌系统 (RandomEncounter)
## 管理城市/荒野中的随机战斗触发
## 附加到玩家节点或场景管理器上

## 遇敌触发信号
signal encounter_triggered

## 每步遇敌概率 (0-1)
@export var encounter_rate: float = 0.02
## 最小步数间隔 (避免连续遇敌)
@export var min_steps_between_encounters: int = 5
## 遇敌区域名称 (决定敌人种类)
@export var area_id: String = "aoduo"

## 上次遇敌后的步数
var _steps_since_encounter: int = 0
## 上次位置
var _last_pos: Vector3 = Vector3.ZERO
## 累计移动距离
var _accumulated_distance: float = 0.0
## 每步距离阈值
const STEP_THRESHOLD: float = 1.0

var _parent_node: Node

func _ready() -> void:
	_parent_node = get_parent()
	if _parent_node is Node3D:
		_last_pos = _parent_node.position

func _process(_delta: float) -> void:
	if not _parent_node is Node3D:
		return

	# 计算移动距离
	var current_pos: Vector3 = _parent_node.position
	var distance = current_pos.distance_to(_last_pos)
	if distance > 0.01:
		_accumulated_distance += distance
		_last_pos = current_pos

		# 每移动 STEP_THRESHOLD 距离算一步
		while _accumulated_distance >= STEP_THRESHOLD:
			_accumulated_distance -= STEP_THRESHOLD
			_step_taken()

## 每步检查是否遇敌
func _step_taken() -> void:
	_steps_since_encounter += 1
	if _steps_since_encounter < min_steps_between_encounters:
		return

	if randf() < encounter_rate:
		_trigger_encounter()

## 触发遇敌
func _trigger_encounter() -> void:
	_steps_since_encounter = 0
	encounter_triggered.emit()
	print("[RandomEncounter] 触发随机战斗! 区域: " + area_id)
	# 通过 GameFlow 进入战斗
	GameFlow.enter_battle()

## 重置遇敌计数 (战斗结束后调用)
func reset_encounter_counter() -> void:
	_steps_since_encounter = 0
