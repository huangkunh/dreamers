extends Node3D
## 城市探索管理器 (CityExplorer)
## 管理城市探索模式，处理随机遇敌、返回世界地图等

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player

## 随机遇敌系统
var _encounter_system: Node

func _ready() -> void:
	# 确保背景音乐播放
	if audio_stream_player and not audio_stream_player.playing:
		audio_stream_player.play()
	# 设置游戏状态
	GameFlow.current_state = GameFlow.GameState.CITY

	# 添加随机遇敌系统到玩家
	if player:
		_encounter_system = load("res://script/system/random_encounter.gd").new()
		_encounter_system.encounter_rate = 0.015  # 1.5% 每步
		_encounter_system.min_steps_between_encounters = 8
		_encounter_system.area_id = "aoduo"
		_encounter_system.encounter_triggered.connect(_on_encounter)
		player.add_child(_encounter_system)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				# 返回世界地图
				GameFlow.return_to_world_map()
			KEY_M:
				# 打开菜单 (TODO)
				print("[CityExplorer] 菜单键按下")

## 遇敌回调
func _on_encounter() -> void:
	print("[CityExplorer] 进入战斗!")
	# 停止背景音乐
	if audio_stream_player:
		audio_stream_player.stop()
	# 切换到战斗场景
	GameFlow.enter_battle()
