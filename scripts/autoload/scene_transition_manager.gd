extends Node
## 场景过渡管理器 (SceneTransitionManager)
## 统一管理场景切换时的数据传递和状态保存
## 解决场景间数据丢失问题

## 场景过渡数据
var _transition_data: Dictionary = {}

## 信号
signal before_scene_change(scene_name: String)
signal after_scene_change(scene_name: String)

## 设置过渡数据
## key: 数据键
## value: 数据值
func set_data(key: String, value) -> void:
	_transition_data[key] = value

## 获取过渡数据
## key: 数据键
## default: 默认值
func get_data(key: String, default = null):
	return _transition_data.get(key, default)

## 清除过渡数据
func clear_data() -> void:
	_transition_data.clear()

## 带数据切换场景
## scene_name: 场景名称
## data: 要传递的数据字典
func change_scene_with_data(scene_name: String, data: Dictionary = {}) -> void:
	# 合并数据
	for key in data.keys():
		_transition_data[key] = data[key]

	before_scene_change.emit(scene_name)
	GameFlow.change_scene(scene_name)
	after_scene_change.emit(scene_name)

## 进入战斗并保存当前场景信息
func enter_battle(enemy_data: Array = [], is_boss: bool = false) -> void:
	# 保存战斗前场景信息
	_transition_data["battle_enemy_data"] = enemy_data
	_transition_data["battle_is_boss"] = is_boss
	_transition_data["battle_return_area"] = GameData.game_flags.get("current_area", "aoduo")

	# 进入战斗
	GameFlow.enter_battle()

## 战斗结束后返回
func return_from_battle() -> void:
	var return_area = _transition_data.get("battle_return_area", "aoduo")
	match return_area:
		"aoduo":
			GameFlow.change_scene("city")
		"wasteland":
			GameFlow.change_scene("wasteland")
		"factory", "factory_ruins":
			GameFlow.change_scene("factory")
		"ant_nest":
			GameFlow.change_scene("ant_nest")
		"ancient_ruins":
			GameFlow.change_scene("ancient_ruins")
		_:
			GameFlow.change_scene("city")

	# 清除战斗数据
	_transition_data.erase("battle_enemy_data")
	_transition_data.erase("battle_is_boss")
	_transition_data.erase("battle_return_area")

## 获取战斗敌人数据
func get_battle_enemies() -> Array:
	return _transition_data.get("battle_enemy_data", [])

## 是否是BOSS战
func is_boss_battle() -> bool:
	return _transition_data.get("battle_is_boss", false)

## 保存当前玩家位置 (用于场景内返回)
func save_player_position(pos: Vector3) -> void:
	_transition_data["saved_player_pos"] = {"x": pos.x, "y": pos.y, "z": pos.z}

## 获取保存的玩家位置
func get_saved_player_position() -> Vector3:
	var pos = _transition_data.get("saved_player_pos", null)
	if pos:
		return Vector3(pos.x, pos.y, pos.z)
	return Vector3.ZERO

## 清除保存的位置
func clear_saved_position() -> void:
	_transition_data.erase("saved_player_pos")
