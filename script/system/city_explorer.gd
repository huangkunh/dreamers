extends Node3D
## 城市探索管理器 (CityExplorer)
## 管理城市探索模式，处理随机遇敌、暂停菜单、战车切换、返回世界地图等

const PAUSE_MENU_SCENE := preload("res://scene/ui/pause_menu.tscn")
const TANK_HUD_SCENE := preload("res://scene/ui/tank_hud.tscn")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player

## 随机遇敌系统
var _encounter_system: Node
## 暂停菜单
var _pause_menu: Control
## 战车HUD
var _tank_hud: Control
## 是否在战车中
var _in_tank: bool = false

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

	# 实例化暂停菜单（初始隐藏）
	_pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(_pause_menu)

	# 实例化战车HUD（初始隐藏）
	_tank_hud = TANK_HUD_SCENE.instantiate()
	add_child(_tank_hud)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				if _pause_menu and _pause_menu.visible:
					_pause_menu.close()
				else:
					GameFlow.return_to_world_map()
			KEY_M:
				if _pause_menu:
					_pause_menu.toggle()
			KEY_T:
				_toggle_tank()

## 切换上下战车
func _toggle_tank() -> void:
	if _in_tank:
		TankSystem.exit_tank()
		_in_tank = false
		# 调整玩家速度等
		if player:
			player.movement_speed = 200
		print("[CityExplorer] 下车，步行模式")
	else:
		# 检查是否拥有战车
		var owned = TankSystem.get_owned_tanks()
		if owned.size() > 0:
			TankSystem.enter_tank(owned[0].id)
			_in_tank = true
			# 战车移动更快
			if player:
				player.movement_speed = 400
			print("[CityExplorer] 上车，战车模式")
		else:
			print("[CityExplorer] 没有战车")

## 遇敌回调
func _on_encounter() -> void:
	print("[CityExplorer] 进入战斗!")
	# 停止背景音乐
	if audio_stream_player:
		audio_stream_player.stop()
	# 切换到战斗场景
	GameFlow.enter_battle()
