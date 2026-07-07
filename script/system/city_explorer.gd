extends Node3D
## 城市探索管理器 (CityExplorer)
## 管理城市探索模式，处理随机遇敌、暂停菜单、战车切换、对话、商店、返回世界地图等

const PAUSE_MENU_SCENE := preload("res://scene/ui/pause_menu.tscn")
const TANK_HUD_SCENE := preload("res://scene/ui/tank_hud.tscn")
const DIALOG_SCENE := preload("res://scene/ui/dialog_system.tscn")
const SHOP_SCENE := preload("res://scene/ui/shop_system.tscn")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player

## 随机遇敌系统
var _encounter_system: Node
## 暂停菜单
var _pause_menu: Control
## 战车HUD
var _tank_hud: Control
## 对话系统
var _dialog_system: Control
## 商店系统
var _shop_system: Control
## 是否在战车中
var _in_tank: bool = false
## 附近可交互的NPC
var _nearby_npc: Node3D = null
## 当前区域ID
var area_id: String = "aoduo"

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
		_encounter_system.area_id = area_id
		_encounter_system.encounter_triggered.connect(_on_encounter)
		player.add_child(_encounter_system)

	# 实例化暂停菜单（初始隐藏）
	_pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(_pause_menu)

	# 实例化战车HUD（初始隐藏）
	_tank_hud = TANK_HUD_SCENE.instantiate()
	add_child(_tank_hud)

	# 实例化对话系统
	_dialog_system = DIALOG_SCENE.instantiate()
	add_child(_dialog_system)

	# 实例化商店系统
	_shop_system = SHOP_SCENE.instantiate()
	add_child(_shop_system)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# 对话/商店打开时禁用其他快捷键
		if _dialog_system and _dialog_system.visible:
			return
		if _shop_system and _shop_system.visible:
			match event.keycode:
				KEY_ESCAPE:
					_shop_system.close_shop()
				_:
					pass
			return

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
			KEY_E:
				_try_interact()

## 尝试与附近NPC交互
func _try_interact() -> void:
	if _nearby_npc:
		var npc_id = _nearby_npc.get_meta("npc_id", "")
		var npc_area = _nearby_npc.get_meta("area_id", area_id)
		if npc_id.is_empty():
			return
		# 检查是否是商店NPC
		var shop_id = _nearby_npc.get_meta("shop_id", "")
		if not shop_id.is_empty():
			_open_shop(shop_id)
			return
		# 普通对话
		var npc_data = NPCData.get_npc_dialog(npc_area, npc_id)
		if npc_data.is_empty():
			_dialog_system.show_dialog("???", "...")
			return
		var dialogs = npc_data.get("dialogs", [])
		if dialogs.is_empty():
			return
		_dialog_system.show_dialog_queue(dialogs)

## 打开商店
func _open_shop(shop_id: String) -> void:
	var items = ShopData.get_shop_items(shop_id)
	var shop_name = ""
	match shop_id:
		"aoduo_weapon": shop_name = "武器店"
		"aoduo_armor": shop_name = "防具店"
		"aoduo_item": shop_name = "道具店"
		"aoduo_accessory": shop_name = "饰品店"
		_: shop_name = "商店"
	_shop_system.open_shop(shop_name, items)

## 设置附近NPC (由NPC的Area3D调用)
func set_nearby_npc(npc: Node3D) -> void:
	_nearby_npc = npc

## 清除附近NPC
func clear_nearby_npc() -> void:
	_nearby_npc = null

## 切换上下战车
func _toggle_tank() -> void:
	if _in_tank:
		TankSystem.exit_tank()
		_in_tank = false
		if player:
			player.movement_speed = 200
		print("[CityExplorer] 下车，步行模式")
	else:
		var owned = TankSystem.get_owned_tanks()
		if owned.size() > 0:
			TankSystem.enter_tank(owned[0].id)
			_in_tank = true
			if player:
				player.movement_speed = 400
			print("[CityExplorer] 上车，战车模式")
		else:
			print("[CityExplorer] 没有战车")

## 遇敌回调
func _on_encounter() -> void:
	print("[CityExplorer] 进入战斗!")
	if audio_stream_player:
		audio_stream_player.stop()
	GameFlow.enter_battle()

## 战斗结束后恢复
func _on_battle_end() -> void:
	if audio_stream_player and not audio_stream_player.playing:
		audio_stream_player.play()
	if _encounter_system:
		_encounter_system.reset_encounter_counter()

## 更新游戏时间
func _process(delta: float) -> void:
	GameData.play_time += delta
